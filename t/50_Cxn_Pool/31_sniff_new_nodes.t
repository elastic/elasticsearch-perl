use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_sniff_client);

## Sniff new nodes

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [],      code => 509, error => 'Cxn' },
    { node => 2, sniff => [ 'two', 'three' ] },
    { node => 3, code => 200, content => 1 },
    { node => 4, code => 200, content => 1 },

    # force sniff
    { node => 3, sniff => [ 'one', 'two', 'three' ] },
    { node => 5, code => 200, content => 1 },
    { node => 6, code => 200, content => 1 },
    { node => 7, code => 200, content => 1 },
    { node => 5, code => 200, content => 1 },
);

ok $t->perform_request()
    && $t->perform_request
    && $t->cxn_pool->schedule_check
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request,
    'Sniff new nodes';

done_testing;
