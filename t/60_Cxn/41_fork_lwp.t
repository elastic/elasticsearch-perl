use lib 't/lib';

$ENV{ES_CXN} = 'LWP';
do "es_sync_fork.pl" or die( $@ || $! );

