use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_noping_client);

## Runaway nodes

my $t = mock_noping_client(
    { nodes => [ 'one', 'two', 'three' ] },

    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },
    { node => 1, code => 509, error   => 'Unavailable' },
    { node => 2, code => 509, error   => 'Unavailable' },
    { node => 3, code => 509, error   => 'Unavailable' },

    # throws unavailable
    { node => 1, code => 200, content => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 200, content => 1 },

);

ok $t->perform_request()
    && $t->perform_request
    && $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Unavailable/
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request,
    'Runaway nodes';

done_testing;

