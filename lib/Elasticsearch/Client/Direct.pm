package Elasticsearch::Client::Direct;

use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';

use Elasticsearch::Util qw(parse_params);
use namespace::autoclean;

has 'cluster' => ( is => 'lazy' );
has 'indices' => ( is => 'lazy' );

__PACKAGE__->_install_api('');

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
    $self->perform_request( { %$defn, name => $name }, $params );
}

#===================================
sub _build_cluster {
#===================================
    my ( $self, $name ) = @_;
    Elasticsearch::Client::Direct::Cluster->new(
        {   transport => $self->transport,
            logger    => $self->logger
        }
    );
}

#===================================
sub _build_indices {
#===================================
    my ( $self, $name ) = @_;
    Elasticsearch::Client::Direct::Indices->new(
        {   transport => $self->transport,
            logger    => $self->logger
        }
    );
}

#===================================
package Elasticsearch::Client::Direct::Cluster;
#===================================
use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('cluster');

#===================================
package Elasticsearch::Client::Direct::Indices;
#===================================
use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('indices');

1;
