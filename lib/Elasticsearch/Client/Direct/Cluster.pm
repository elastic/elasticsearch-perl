#===================================
package Elasticsearch::Client::Direct::Cluster;
#===================================
use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('cluster');

1;
