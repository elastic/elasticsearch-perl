use lib 't/lib';

use Test::More skip_all => "Hijk doesn't work with Netty4";
$ENV{ES_VERSION} = '5_0';
$ENV{ES_CXN} = 'Hijk';
do "es_sync_fork.pl" or die( $@ || $! );

