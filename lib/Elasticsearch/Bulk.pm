package Elasticsearch::Bulk;

use Moo;
use Elasticsearch::Util qw(parse_params);
use namespace::autoclean;

has 'es'                => ( is => 'ro', required => 1 );
has 'max_docs'          => ( is => 'rw', default  => 1_000 );
has 'max_size'          => ( is => 'rw', default  => 500_000 );
has 'on_success'        => ( is => 'ro', default  => 0 );
has 'on_error'          => ( is => 'lazy' );
has 'on_conflict'       => ( is => 'ro', default  => 0 );
has 'source_with_error' => ( is => 'ro', default  => 0 );
has 'verbose'           => ( is => 'ro' );

has '_buffer' => ( is => 'ro', default => sub { [] } );
has '_buffer_size' => ( is => 'rw', default => 0 );
has '_serializer'  => ( is => 'lazy' );
has '_bulk_args'   => ( is => 'ro' );

our $Conflict = qr/
    DocumentAlreadyExistsException
  | :.version.conflict,.current.\[(\d+)\]
  /x;

#===================================
sub _build_on_error {
#===================================
    my $self       = shift;
    my $serializer = $self->_serializer;
    return sub {
        my ( $action, $result, $src ) = @_;
        warn( "Bulk error [%s]: %s ", $action, $serializer->encode($result) );
    };
}

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
sub _build_serializer { shift->es->serializer }
#===================================

my @Metadata_Keys = qw(
    index type id routing parent timestamp ttl version version_type
);

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
}

#===================================
sub delete_ids {
#===================================
    my $self = shift;
    my @meta = map { { _id => $_ } } @_;
    $self->add_action( 'delete', @meta );
}

#===================================
sub _add {
#===================================
    my $self   = shift;
    my $action = shift;
    while ( my $next = shift() ) {
        $self->add_action( $action, $next );
    }
}

#===================================
sub add_action {
#===================================
    my $self = shift;
    while (@_) {
        my $action = shift;
        my $params = shift or die "foo";
        my %metadata;
        for (@Metadata_Keys) {
            my $val
                = exists $params->{$_}    ? $params->{$_}
                : exists $params->{"_$_"} ? $params->{"_$_"}
                :                           next;
            $metadata{"_$_"} = $val;
        }
        my $source;
        if ( $action eq 'update' ) {
            for (qw(doc upsert script params lang)) {
                $source->{$_} = $params->{$_} if exists $params->{$_};
            }
        }
        elsif ( $action ne 'delete' ) {
            $source = $params->{_source} || $params->{source} || {};
        }
        $self->_add_to_buffer( { $action => \%metadata }, $source );
    }
}

#===================================
sub _add_to_buffer {
#===================================
    my $self       = shift;
    my $buffer     = $self->_buffer;
    my $size       = $self->_buffer_size;
    my $serializer = $self->_serializer;

    while ( my $hash = shift ) {
        push @{$buffer}, $serializer->encode($hash);
        $size += length $buffer->[-1] + 1;
    }
    $self->_buffer_size($size);
    if ( my $max_size = $self->max_size ) {
        return $self->flush if $max_size >= $size;
    }
    if ( my $max_docs = $self->max_docs ) {
        return $self->flush if $max_docs >= @$buffer;
    }
}

#===================================
sub flush {
#===================================
    my $self   = shift;
    my $buffer = $self->_buffer;

    my $results = $self->es->bulk( %{ $self->bulk_args }, body => $buffer );
    $self->_report($results);
    if ( $self->verbose ) {
        local $| = 1;
        print ".";
    }

    @{$buffer} = ();
    $self->_buffer_size(0);

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

    my $inc_src    = $self->doc_with_error;
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
                    = $inc_src && $action ne 'delete'
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
