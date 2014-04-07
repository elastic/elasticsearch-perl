use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
use MockAsyncCxn qw(mock_static_client);

## Nodes initially unavailable

my $t = mock_static_client(
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

ok !eval { $t->perform_sync_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_sync_request }
    && $@ =~ /NoNodes/
    && $t->perform_sync_request
    && $t->perform_sync_request,
    'Nodes initially unavailable';

done_testing;
