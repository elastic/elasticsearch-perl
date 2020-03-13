use Test::More;
use lib 't/lib';

if ($ENV{ES} =~ /https/) {
    plan skip_all => 'Hijk does not support SSL';
}
$ENV{ES_VERSION} = '6_0';
$ENV{ES_CXN} = 'Hijk';
do "es_sync_fork.pl" or die( $@ || $! );
