use lib 't/lib';

$ENV{ES_CXN} = 'AEHTTP';
do "es_async_fork.pl" or die $!;

