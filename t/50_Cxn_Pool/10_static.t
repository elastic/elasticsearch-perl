use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn;

my $t;

## Both nodes respond - check ping before first use

$t = mock_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
);

ok $t->perform_request()
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request,
    'Ping before first use';

## One node missing at first, then joins later
$t = mock_client(
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

## One node fails with a Cxn error, then rejoins

$t = mock_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 500, error => 'Cxn' },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },

    # force ping on missing node
    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 200, content => 1 },
);

ok $t->perform_request
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request,
    'One node throws Cxn';

# force ping on missing node
$t->cxn_pool->cxns->[0]->next_ping(-1);

ok $t->perform_request && $t->perform_request && $t->perform_request,
    'Failed node recovers';

## One node fails with a Timeout error, then rejoins

$t = mock_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 500, error => 'Timeout' },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },

);

ok $t->perform_request
    && $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && $t->perform_request,
    'One node throws Timeout then recovers';

## One node fails with a Timeout error and causes good node to timeout

$t = mock_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 500, error => 'Timeout' },
    { node => 2, ping => 1 },
    { node => 2, code => 500, error => 'Timeout' },
    { node => 1, ping => 0 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },

);

ok $t->perform_request
    && $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && $t->perform_request,
    'One node throws Timeout, causing Timeout on other node';

## All nodes fail

$t = mock_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 500, error => 'Cxn' },
    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },

);

ok $t->perform_request
    && $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && $t->perform_request
    && $t->perform_request,
    'Both nodes fails then recover';

## Nodes initially unavailable

$t = mock_client(
    { nodes => [ 'one', 'two' ] },

    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },

);

ok !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && $t->perform_request
    && $t->perform_request,
    'Nodes initially unavailable';

done_testing;

#===================================
sub mock_client {
#===================================
    my $params = shift;
    return Elasticsearch->new(
        cxn            => '+Elasticsearch::MockCxn',
        mock_responses => \@_,
        %$params,
    )->transport;
}
