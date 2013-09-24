package Elasticsearch::Bulk;

use Moo;
use Elasticsearch::Util qw(parse_params throw);
use Try::Tiny;
use namespace::autoclean;

has 'es'                => ( is => 'ro', required => 1 );
has 'max_docs'          => ( is => 'rw', default  => 1_000 );
has 'max_size'          => ( is => 'rw', default  => 500_000 );
has 'on_success'        => ( is => 'ro', default  => 0 );
has 'on_error'          => ( is => 'lazy' );
has 'on_conflict'       => ( is => 'ro', default  => 0 );
has 'source_with_error' => ( is => 'ro', default  => 0 );
has 'verbose'           => ( is => 'rw' );

has '_buffer' => ( is => 'ro', default => sub { [] } );
has '_buffer_size'  => ( is => 'rw', default => 0 );
has '_buffer_count' => ( is => 'rw', default => 0 );
has '_serializer'   => ( is => 'lazy' );
has '_logger'       => ( is => 'lazy' );
has '_bulk_args'    => ( is => 'ro' );

our $Conflict = qr/
    DocumentAlreadyExistsException
  | :.version.conflict,.current.\[(\d+)\]
  /x;

our %Actions = map { $_ => 1 } qw(index create update delete);
our @Metadata_Keys = qw(
    index type id routing parent timestamp ttl version version_type
);

#===================================
sub _build_on_error {
#===================================
    my $self       = shift;
    my $serializer = $self->_serializer;
    return sub {
        my ( $action, $result, $src ) = @_;
        $self->logger->warning(
            "Bulk error [$action]: " . $serializer->encode($result) );
    };
}

#===================================
sub _build__serializer { shift->es->transport->serializer }
sub _build__logger     { shift->es->logger }
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
    my $self     = shift;
    my $buffer   = $self->_buffer;
    my $max_size = $self->max_size;
    my $max_docs = $self->max_docs;

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
            || $max_docs && $count >= $max_docs;
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
            || throw( 'Param',
            "Missing <_source> in <$action>: " . $serializer->encode($orig) );
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

    my $results = try {
        $self->es->bulk( %{ $self->_bulk_args }, body => $self->_buffer );
    }
    catch {
        my $error = $_;
        $self->clear_buffer;
        die $error;
    };

    $self->_report($results);
    $self->clear_buffer;

    if ( $self->verbose ) {
        local $| = 1;
        print ".";
    }

    return 1;
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
    my $index     = $self->index;
    my $type      = $self->type;
    my $transform = $params->{transform};
    my $src       = $params->{source};

    if ( ref $src eq 'HASH' ) {
        require Elasticsearch::Scroll;

        my $scroll = Elasticsearch::Scroll->new(
            es        => $self->es,
            scan_type => 'search',
            size      => 500,
            %$src
        );

        $src = sub {
            $scroll->refill_buffer;
            $scroll->drain_buffer;
        };
    }

    my $cb = sub {
        my %doc = %{ shift() };
        delete $doc{_index} if $index;
        delete $doc{_type}  if $type;

        $doc{_version_type} = 'external'
            if $doc{_version};

        if ( my $fields = delete $doc{fields} ) {
            for (qw(_routing parent)) {
                $doc{$_} = $fields->{$_}
                    if exists $fields->{$_};
            }
        }
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
}

#===================================
sub _report {
#===================================
    my ( $self, $results ) = @_;
    my $on_success  = $self->on_success;
    my $on_error    = $self->on_error;
    my $on_conflict = $self->on_conflict;

    return unless $on_success || $on_error || $on_conflict;

    my $incl_src   = $self->source_with_error;
    my $buffer     = $self->_buffer;
    my $serializer = $self->_serializer;

    my $i = 0;
    my $j = 0;

    if ( $on_success || $on_error || $on_conflict ) {
        for my $item ( @{ $results->{items} } ) {
            my ( $action, $result ) = %$item;
            my @args = ($action);
            if ( my $error = $result->{error} ) {
                my $src
                    = $incl_src && $action ne 'delete'
                    ? $serializer->decode( $buffer->[ $i + 1 ] )
                    : $j;

                $on_conflict && $error =~ /$Conflict/
                    ? $on_conflict->( $action, $result, $src, $1 )
                    : $on_error && $on_error->( $action, $result, $src );
            }
            else {
                $on_success && $on_success->( $action, $result );
            }
            $i += $action eq 'delete' ? 1 : 2;
            $j++;
        }
    }
}

1;

__END__

# ABSTRACT: A helper utility for the Bulk API

=head1 DESCRIPTION

Docs to follow soon
