use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
use MockAsyncCxn qw(mock_sniff_client);

## Nodes initially unavailable

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [], error => 'Cxn', code => 509 },
    { node => 2, sniff => [], error => 'Cxn', code => 509 },

    # NoNodes

    { node => 3, sniff => [], error => 'Cxn', code => 509 },
    { node => 4, sniff => [], error => 'Cxn', code => 509 },

    # NoNodes

    { node => 5, sniff => ['one'] },
    { node => 6, sniff => ['one'] },
    { node => 7, code  => 200, content => 1 },
    { node => 7, code  => 200, content => 1 },

    # force sniff
    { node => 7, sniff => [ 'one', 'two' ] },
    { node => 8, code => 200, content => 1 },
    { node => 9, code => 200, content => 1 },

);

ok !eval { $t->perform_sync_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_sync_request }
    && $@ =~ /NoNodes/
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->cxn_pool->schedule_check
    && $t->perform_sync_request
    && $t->perform_sync_request,
    'Sniff unavailable nodes while starting up';

done_testing;
