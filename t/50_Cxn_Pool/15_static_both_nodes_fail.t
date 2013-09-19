use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_static_client);

## All nodes fail

my $t = mock_static_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 509, error => 'Cxn' },
    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 2, ping => 0 },
    { node => 1, ping => 0 },

    # NoNodes
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },

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

done_testing;

