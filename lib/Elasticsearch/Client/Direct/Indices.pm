#===================================
package Elasticsearch::Client::Direct::Indices;
#===================================
use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('indices');

1;
