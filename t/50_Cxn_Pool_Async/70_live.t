use Test::More;
use Test::Deep;
use Test::Exception;
use AE;
use strict;
use warnings;
use lib 't/lib';

my $es;
local $ENV{ES_CXN_POOL};

$ENV{ES_CXN_POOL} = 'Async::Static';
$es = do "es_async.pl";

is wait_for( $es->info )->{status}, 200, 'CxnPool::Async::Static';

$ENV{ES_CXN_POOL} = 'Async::Static::NoPing';
$es = do "es_async.pl";
is wait_for( $es->info )->{status}, 200, 'CxnPool::Async::Static::NoPing';

$ENV{ES_CXN_POOL} = 'Async::Sniff';
$es = do "es_async.pl";
is wait_for( $es->info )->{status}, 200, 'CxnPool::Async::Sniff';

my ($node) = values %{
    (   wait_for(
            $es->transport->cxn_pool->next_cxn->then(
                sub { shift()->sniff }
            )
        )
    )[1]
};
ok $node->{http}{max_content_length_in_bytes}, 'Sniffs max_content length';

done_testing;

