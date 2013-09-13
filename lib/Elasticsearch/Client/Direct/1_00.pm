package Elasticsearch::Client::Direct::1_00;

use Moo;
with 'Elasticsearch::Role::API::1_00';
with 'Elasticsearch::Role::Client::Direct';

use Elasticsearch::Util qw(parse_params);
use namespace::autoclean;

has 'cluster' => ( is => 'lazy' );
has 'indices' => ( is => 'lazy' );

__PACKAGE__->_install_actions('');

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
sub _build_cluster {
#===================================
    my ( $self, $name ) = @_;
    Elasticsearch::Client::Direct::Cluster::1_00->new(
        {   transport => $self->transport,
            logger    => $self->logger
        }
    );
}

#===================================
sub _build_indices {
#===================================
    my ( $self, $name ) = @_;
    Elasticsearch::Client::Direct::Indices::1_00->new(
        {   transport => $self->transport,
            logger    => $self->logger
        }
    );
}

#===================================
package Elasticsearch::Client::Direct::Cluster::1_00;
#===================================
use Moo;
with 'Elasticsearch::Role::API::1_00';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_actions('cluster');

#===================================
package Elasticsearch::Client::Direct::Indices::1_00;
#===================================
use Moo;
with 'Elasticsearch::Role::API::1_00';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_actions('indices');

1;
