use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_sniff_client);

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
    { node => 6, code  => 200, content => 1 },
    { node => 6, code  => 200, content => 1 },

    # force sniff
    { node => 6, sniff => [ 'one', 'two' ] },
    { node => 7, code => 200, content => 1 },
    { node => 8, code => 200, content => 1 },

);

ok !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && $t->perform_request
    && $t->perform_request
    && $t->cxn_pool->schedule_check
    && $t->perform_request
    && $t->perform_request,
    'Sniff unavailable nodes while starting up';

done_testing;
