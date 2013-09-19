use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_sniff_client);

## Sniff all nodes fail

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 509, error   => 'Cxn' },
    { node => 2, sniff => [], error => 'Cxn', code => 509 },
    { node => 3, sniff => [], error => 'Cxn', code => 509 },
    { node => 4, sniff => [], error => 'Cxn', code => 509 },
    { node => 5, sniff => [], error => 'Cxn', code => 509 },

    # throws NoNodes

    { node => 2, sniff => [], error => 'Cxn', code => 509 },
    { node => 3, sniff => [], error => 'Cxn', code => 509 },
    { node => 6, sniff => [], error => 'Cxn', code => 509 },
    { node => 7, sniff => [], error => 'Cxn', code => 509 },

    # throws NoNodes

    { node => 2, sniff => [ 'one', 'two' ] },
    { node => 8, code => 200, content => 1 },
    { node => 9, code => 200, content => 1 },
    { node => 8, code => 200, content => 1 },
);

ok $t->perform_request()
    && !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_request }
    && $@ =~ /NoNodes/
    && $t->perform_request,
    'Sniff after all nodes fail';

done_testing;
