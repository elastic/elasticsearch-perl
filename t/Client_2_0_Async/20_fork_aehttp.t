use lib 't/lib';

$ENV{ES_VERSION} = '2_0';
$ENV{ES_CXN} = 'AEHTTP';
do "es_async_fork.pl" or die( $@ || $! );

