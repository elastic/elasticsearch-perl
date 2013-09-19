use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_sniff_client);

## Sniff when bad node timesout causing good node to timeout too

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 509, error   => 'Timeout' },

    # throws Timeout

    { node => 2, sniff => ['one'] },
    { node => 4, code  => 509, error => 'Timeout' },

    # throws Timeout

    { node => 4, sniff => ['one'] },
    { node => 5, code  => 200, content => 1 },

    # force sniff
    { node => 5, sniff => [ 'one', 'two' ] },
    { node => 6, code => 200, content => 1 },
    { node => 7, code => 200, content => 1 },
);

ok $t->perform_request()
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && $t->perform_request
    && $t->cxn_pool->schedule_check
    && $t->perform_request
    && $t->perform_request,
    'Sniff after both nodes timeout';

done_testing;
