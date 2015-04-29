package Search::Elasticsearch::Role::Bulk;

use Moo::Role;
requires 'add_action', 'flush';

use Search::Elasticsearch::Util qw(parse_params throw);
use namespace::clean;

has 'es'          => ( is => 'ro', required => 1 );
has 'max_count'   => ( is => 'rw', default  => 1_000 );
has 'max_size'    => ( is => 'rw', default  => 1_000_000 );
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
sub _build__serializer { shift->es->transport->serializer }
#===================================

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
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %args;
    for (qw(index type consistency refresh replication timeout)) {
        $args{$_} = $params->{$_}
            if exists $params->{$_};
    }
    $params->{_bulk_args} = \%args;
    return $params;
}

#===================================
sub index {
#===================================
    shift->add_action( map { ( 'index' => $_ ) } @_ );
}

#===================================
sub create {
#===================================
    shift->add_action( map { ( 'create' => $_ ) } @_ );
}

#===================================
sub delete {
#===================================
    shift->add_action( map { ( 'delete' => $_ ) } @_ );
}

#===================================
sub update {
#===================================
    shift->add_action( map { ( 'update' => $_ ) } @_ );
}

#===================================
sub create_docs {
#===================================
    my $self = shift;
    $self->add_action( map { ( 'create' => { _source => $_ } ) } @_ );
}

#===================================
sub delete_ids {
#===================================
    my $self = shift;
    $self->add_action( map { ( 'delete' => { _id => $_ } ) } @_ );
}

#===================================
sub _encode_action {
#===================================
    my $self   = shift;
    my $action = shift || '';
    my $orig   = shift;

    throw( 'Param', "Unrecognised action <$action>" )
        unless $Actions{$action};

    throw( 'Param', "Missing <params> for action <$action>" )
        unless ref($orig) eq 'HASH';

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

    throw( 'Param', "Missing required param <index>" )
        unless $metadata{_index} || $self->_bulk_args->{index};
    throw( 'Param', "Missing required param <type>" )
        unless $metadata{_type} || $self->_bulk_args->{type};

    my $source;
    if ( $action eq 'update' ) {
        for (qw(doc upsert doc_as_upsert script params lang detect_noop)) {
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
            "Missing <source> for action <$action>: "
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
sub _report {
#===================================
    my ( $self, $buffer, $results ) = @_;
    my $on_success  = $self->on_success;
    my $on_error    = $self->on_error;
    my $on_conflict = $self->on_conflict;

    # assume errors if key not present, bwc
    $results->{errors} = 1 unless exists $results->{errors};

    return
        unless $on_success
        || ( $results->{errors} and $on_error || $on_conflict );

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

#===================================
sub clear_buffer {
#===================================
    my $self = shift;
    @{ $self->_buffer } = ();
    $self->_buffer_size(0);
    $self->_buffer_count(0);
}

#===================================
sub _doc_transformer {
#===================================
    my ( $self, $params ) = @_;

    my $bulk_args = $self->_bulk_args;
    my %allowed = map { $_ => 1, "_$_" => 1 } ( @Metadata_Keys, 'source' );
    $allowed{fields} = 1;

    delete @allowed{ 'index', '_index' } if $bulk_args->{index};
    delete @allowed{ 'type',  '_type' }  if $bulk_args->{type};

    my $version_type = $params->{version_type};
    my $transform    = $params->{transform};

    return sub {
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
}

1;

# ABSTRACT: Provides common functionality to L<Elasticseach::Bulk> and L<Search::Elasticsearch::Async::Bulk>
