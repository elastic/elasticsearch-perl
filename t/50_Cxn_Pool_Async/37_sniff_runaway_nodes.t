use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
use MockAsyncCxn qw(mock_sniff_client);

## Runaway nodes (ie wrong HTTP response codes signal node failure, instead of
## request failure)

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, sniff => [ 'one', 'two' ] },
    { node => 3, code  => 200,     content => 1 },
    { node => 4, code  => 503,     error   => 'Unavailable' },
    { node => 3, sniff => [ 'one', 'two' ] },
    { node => 4, sniff => [ 'one', 'two' ] },
    { node => 5, code  => 503,     error   => 'Unavailable' },

    # throw Unavailable: too many retries

    { node => 6, sniff => [ 'one', 'two' ] },
    { node => 5, sniff => [ 'one', 'two' ] },
    { node => 7, code  => 503,     error => 'Unavailable' },
    { node => 8, sniff => [ 'one', 'two' ] },
    { node => 7, sniff => [ 'one', 'two' ] },
    { node => 9, code  => 503,     error => 'Unavailable' },

    # throw Unavailable: too many retries

    { node => 10, sniff => [ 'one', 'two' ] },
    { node => 9,  sniff => [ 'one', 'two' ] },
    { node => 11, code => 200, content => 1 },
);

ok $t->perform_sync_request
    && !eval { $t->perform_sync_request }
    && $@ =~ /Unavailable/
    && !eval { $t->perform_sync_request }
    && $@ =~ /Unavailable/
    && $t->perform_sync_request,
    "Runaway nodes";

done_testing;
