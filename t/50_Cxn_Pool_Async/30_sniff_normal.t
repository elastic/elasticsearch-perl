use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
use MockAsyncCxn qw(mock_sniff_client);

## Both nodes respond - check ping before first use

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { sniff => [ 'one', 'two' ] },
    { sniff => [ 'one', 'two' ] },
    { node => 3, code => 200, content => 1 },
    { node => 4, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },
    { node => 4, code => 200, content => 1 },
);

ok $t->perform_sync_request()
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->perform_sync_request,
    'Sniff before first use';

done_testing;
