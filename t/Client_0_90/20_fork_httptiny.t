use lib 't/lib';

$ENV{ES_VERSION} = '0_90';
$ENV{ES_CXN} = 'HTTPTiny';
do "es_sync_fork.pl" or die( $@ || $! );

