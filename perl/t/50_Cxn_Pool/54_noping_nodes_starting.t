use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use MockCxn qw(mock_noping_client);

## Nodes initially unavailable

my $t = mock_noping_client(
    { nodes => [ 'one', 'two', 'three' ] },

    { node => 1, code => 509, error   => 'Cxn' },
    { node => 2, code => 509, error   => 'Cxn' },
    { node => 3, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },

    # force check
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },
);

ok $t->perform_request()
    && $t->perform_request
    && $t->cxn_pool->cxns->[0]->force_ping
    && $t->cxn_pool->cxns->[1]->force_ping
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request,
    'Nodes starting';

done_testing;

