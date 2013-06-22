package Elasticsearch::Role::Client::Raw;

use Moo::Role;
with 'Elasticsearch::Role::Client';
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params);

has 'cluster' => ( is => 'ro' );
has 'indices' => ( is => 'ro' );

#===================================
sub create {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $params->{op_type} = 'create';
    $self->_index( 'create', $params );
}

#===================================
sub index {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $self->_index( 'index', $params );
}

#===================================
sub _index {
#===================================
    my ( $self, $name, $params ) = @_;
    my $defn = $self->api->{index};
    unless ( defined $params->{id} and length $params->{id} ) {
        $defn = { %$defn, method => 'POST' };
    }
    $self->perform_request( $name, $defn, $params );
}

#===================================
around 'BUILDARGS' => sub {
#===================================
    my $orig = shift;
    my ( $class, $params ) = parse_params(@_);

    my $indices_class = my $cluster_class = $class;
    $cluster_class =~ s/::Raw/::Raw::Cluster/;
    $indices_class =~ s/::Raw/::Raw::Indices/;

    $params->{cluster} = $cluster_class->new($params);
    $params->{indices} = $indices_class->new($params);
    return $orig->( $class, $params );
};

1;
