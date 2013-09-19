use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_sniff_client);

## Both nodes respond - check ping before first use

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { sniff => [ 'one', 'two' ] },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },
);

ok $t->perform_request()
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request,
    'Sniff before first use';

done_testing;
