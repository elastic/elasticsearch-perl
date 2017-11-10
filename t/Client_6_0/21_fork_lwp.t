use lib 't/lib';

$ENV{ES_VERSION} = '6_0';
$ENV{ES_CXN} = 'LWP';
do "es_sync_fork.pl" or die( $@ || $! );

