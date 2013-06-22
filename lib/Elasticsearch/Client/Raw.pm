package Elasticsearch::Client::Raw;

use Moo;
with 'Elasticsearch::Role::Client';
with 'Elasticsearch::Role::Client::Raw';
with 'Elasticsearch::Role::API::1_00_00';
use namespace::autoclean;

Elasticsearch::Util::install_actions();

#===================================
package Elasticsearch::Client::Raw::Cluster;
#===================================
use Moo;
with 'Elasticsearch::Role::Client';
with 'Elasticsearch::Role::API::1_00_00';
use namespace::autoclean;

Elasticsearch::Util::install_actions('cluster');

#===================================
package Elasticsearch::Client::Raw::Indices;
#===================================
use Moo;
with 'Elasticsearch::Role::Client';
with 'Elasticsearch::Role::API::1_00_00';
use namespace::autoclean;

Elasticsearch::Util::install_actions('indices');

1;
