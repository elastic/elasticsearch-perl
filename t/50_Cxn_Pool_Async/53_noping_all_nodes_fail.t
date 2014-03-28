use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
use MockAsyncCxn qw(mock_noping_client);

## All nodes fail and recover

my $t = mock_noping_client(
    { nodes => [ 'one', 'two', 'three' ] },

    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 509, error   => 'Cxn' },
    { node => 3, code => 200, content => 1 },
    { node => 1, code => 509, error   => 'Cxn' },
    { node => 3, code => 509, error   => 'Cxn' },
    { node => 2, code => 200, content => 1 },

    # force check
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },
);

ok $t->perform_sync_request()
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->cxn_pool->cxns->[0]->force_ping
    && $t->cxn_pool->cxns->[2]->force_ping
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->perform_sync_request,
    'All nodes fail and recover';

done_testing;

