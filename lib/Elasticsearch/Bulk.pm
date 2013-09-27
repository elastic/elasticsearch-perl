package Elasticsearch::Bulk;

use Moo;
use Elasticsearch::Util qw(parse_params throw);
use Try::Tiny;
use namespace::clean;

has 'es'          => ( is => 'ro', required => 1 );
has 'max_count'   => ( is => 'rw', default  => 1_000 );
has 'max_size'    => ( is => 'rw', default  => 500_000 );
has 'on_success'  => ( is => 'ro', default  => 0 );
has 'on_error'    => ( is => 'lazy' );
has 'on_conflict' => ( is => 'ro', default  => 0 );
has 'verbose'     => ( is => 'rw' );

has '_buffer' => ( is => 'ro', default => sub { [] } );
has '_buffer_size'  => ( is => 'rw', default => 0 );
has '_buffer_count' => ( is => 'rw', default => 0 );
has '_serializer'   => ( is => 'lazy' );
has '_bulk_args'    => ( is => 'ro' );

our $Conflict = qr/
    DocumentAlreadyExistsException
  | :.version.conflict,.current.\[(\d+)\]
  /x;

our %Actions = (
    'index'  => 1,
    'create' => 1,
    'update' => 1,
    'delete' => 1
);

our @Metadata_Keys = (
    'index',  'type',      'id',  'routing',
    'parent', 'timestamp', 'ttl', 'version',
    'version_type'
);

#===================================
sub _build_on_error {
#===================================
    my $self       = shift;
    my $serializer = $self->_serializer;
    return sub {
        my ( $action, $result, $src ) = @_;
        warn( "Bulk error [$action]: " . $serializer->encode($result) );
    };
}

#===================================
sub _build__serializer { shift->es->transport->serializer }
#===================================

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %args;
    for (qw(index type consistency refresh replication)) {
        $args{$_} = $params->{$_}
            if exists $params->{$_};
    }
    $params->{_bulk_args} = \%args;
    return $params;
}

#===================================
sub index  { shift->_add( 'index',  @_ ) }
sub create { shift->_add( 'create', @_ ) }
sub delete { shift->_add( 'delete', @_ ) }
sub update { shift->_add( 'update', @_ ) }
#===================================

#===================================
sub create_docs {
#===================================
    my $self = shift;
    while ( my $next = shift() ) {
        $self->add_action( 'create', { _source => $next } );
    }
    1;
}

#===================================
sub delete_ids {
#===================================
    my $self = shift;
    $self->delete( map { { _id => $_ } } @_ );
}

#===================================
sub _add {
#===================================
    my $self   = shift;
    my $action = shift;
    while ( my $next = shift() ) {
        $self->add_action( $action, $next );
    }
    1;
}

#===================================
sub add_action {
#===================================
    my $self      = shift;
    my $buffer    = $self->_buffer;
    my $max_size  = $self->max_size;
    my $max_count = $self->max_count;

    while (@_) {
        my $action = shift || '';
        throw( 'Param', "Unrecognised action <$action>" )
            unless $Actions{$action};

        my $params = shift;
        throw( 'Param', "Missing <params> for action <$action>" )
            unless ref($params) eq 'HASH';

        my @json = $self->_encode_action( $action, $params );
        push @$buffer, @json;

        my $size = $self->_buffer_size;
        $size += length($_) + 1 for @json;
        $self->_buffer_size($size);

        my $count = $self->_buffer_count( $self->_buffer_count + 1 );

        $self->flush
            if ( $max_size && $size >= $max_size )
            || $max_count && $count >= $max_count;
    }
    return 1;
}

#===================================
sub _encode_action {
#===================================
    my ( $self, $action, $orig ) = @_;
    my %metadata;
    my $params     = {%$orig};
    my $serializer = $self->_serializer;

    for (@Metadata_Keys) {
        my $val
            = exists $params->{$_}    ? delete $params->{$_}
            : exists $params->{"_$_"} ? delete $params->{"_$_"}
            :                           next;
        $metadata{"_$_"} = $val;
    }

    my $source;
    if ( $action eq 'update' ) {
        for (qw(doc upsert doc_as_upsert script params lang)) {
            $source->{$_} = delete $params->{$_}
                if exists $params->{$_};
        }
    }
    elsif ( $action ne 'delete' ) {
        $source
            = delete $params->{_source}
            || delete $params->{source}
            || throw(
            'Param',
            "Missing <_source> for action <$action>: "
                . $serializer->encode($orig)
            );
    }

    throw(    "Unknown params <"
            . ( join ',', sort keys %$params )
            . "> in <$action>: "
            . $serializer->encode($orig) )
        if keys %$params;

    return map { $serializer->encode($_) }
        grep {$_} ( { $action => \%metadata }, $source );
}

#===================================
sub flush {
#===================================
    my $self = shift;

    return { items => [] }
        unless $self->_buffer_size;

    if ( $self->verbose ) {
        local $| = 1;
        print ".";
    }
    my $results = try {
        $self->es->bulk( %{ $self->_bulk_args }, body => $self->_buffer );
    }
    catch {
        my $error = $_;
        $self->clear_buffer
            if $error->is('Request')
            and not $error->is('Unavailable');

        die $error;
    };
    $self->clear_buffer;
    $self->_report($results);
    return defined wantarray ? $results : undef;
}

#===================================
sub clear_buffer {
#===================================
    my $self = shift;
    @{ $self->_buffer } = ();
    $self->_buffer_size(0);
    $self->_buffer_count(0);
}

#===================================
sub reindex {
#===================================
    my ( $self, $params ) = parse_params(@_);
    my $src = $params->{source}
        or die "Missing required param <source>";
    my $transform    = $params->{transform};
    my $version_type = $params->{version_type};

    if ( ref $src eq 'HASH' ) {
        require Elasticsearch::Scroll;

        my $scroll = Elasticsearch::Scroll->new(
            es          => $self->es,
            search_type => 'scan',
            size        => 500,
            %$src
        );

        $src = sub {
            $scroll->refill_buffer;
            $scroll->drain_buffer;
        };

        print "Reindexing " . $scroll->total . " docs\n"
            if $self->verbose;
    }

    my $bulk_args = $self->_bulk_args;
    my %allowed = map { $_ => 1, "_$_" => 1 } ( @Metadata_Keys, 'source' );
    $allowed{fields} = 1;
    delete @allowed{ 'index', '_index' } if $bulk_args->{index};
    delete @allowed{ 'type',  '_type' }  if $bulk_args->{type};

    my $cb = sub {
        my %doc = %{ shift() };
        for ( keys %doc ) {
            delete $doc{$_} unless $allowed{$_};
        }

        if ( my $fields = delete $doc{fields} ) {
            for (qw(_routing routing _parent parent)) {
                $doc{$_} = $fields->{$_}
                    if exists $fields->{$_};
            }
        }
        $doc{_version_type} = $version_type if $version_type;

        return \%doc unless $transform;
        return $transform->( \%doc );
    };

    while ( my @docs = $src->() ) {
        for my $doc (@docs) {
            $doc = $cb->($doc) or next;
            $self->index($doc);
        }
    }
    $self->flush;
    return 1;
}

#===================================
sub _report {
#===================================
    my ( $self, $results ) = @_;
    my $on_success  = $self->on_success;
    my $on_error    = $self->on_error;
    my $on_conflict = $self->on_conflict;

    return unless $on_success || $on_error || $on_conflict;

    my $buffer     = $self->_buffer;
    my $serializer = $self->_serializer;

    my $j = 0;

    for my $item ( @{ $results->{items} } ) {
        my ( $action, $result ) = %$item;
        my @args = ($action);
        if ( my $error = $result->{error} ) {
            $on_conflict && $error =~ /$Conflict/
                ? $on_conflict->( $action, $result, $j, $1 )
                : $on_error && $on_error->( $action, $result, $j );
        }
        else {
            $on_success && $on_success->( $action, $result, $j );
        }
        $j++;
    }
}

1;

__END__

# ABSTRACT: A helper utility for the Bulk API

=head1 DESCRIPTION

Docs to follow soon
