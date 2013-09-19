use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_static_client);

## One node missing at first, then joins later
my $t = mock_static_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 0 },
    { node => 1, code => 200, content => 1 },
    { node => 1, code => 200, content => 1 },

    # force ping on missing node
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
);

ok $t->perform_request && $t->perform_request && $t->perform_request,
    'One node missing';

# force ping on missing node
$t->cxn_pool->cxns->[1]->next_ping(-1);

ok $t->perform_request && $t->perform_request && $t->perform_request,
    'Missing node joined - 2';

done_testing;

