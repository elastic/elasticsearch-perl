use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use MockCxn qw(mock_sniff_client);

## Sniff after Timeout error

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 509, error   => 'Timeout' },

    # throws Timeout

    { node => 2, sniff => ['one'] },
    { node => 4, code  => 200, content => 1 },
    { node => 4, code  => 200, content => 1 },

    # force sniff
    { node => 4, sniff => [ 'one', 'two' ] },
    { node => 5, code => 200, content => 1 },
    { node => 6, code => 200, content => 1 },
);

ok $t->perform_request()
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && $t->perform_request
    && $t->perform_request
    && $t->cxn_pool->schedule_check
    && $t->perform_request
    && $t->perform_request,
    'Sniff after timeout';

done_testing;
