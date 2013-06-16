package Elasticsearch::Role::API;

use Moo::Role;
with 'Elasticsearch::Role::Error';

has 'logger'    => ( is => 'ro', required => 1 );
has 'transport' => ( is => 'ro', required => 1 );

1;
