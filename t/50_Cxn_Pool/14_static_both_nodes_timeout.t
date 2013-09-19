use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_static_client);

## One node fails with a Timeout error and causes good node to timeout

my $t = mock_static_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 509, error => 'Timeout' },
    { node => 2, ping => 1 },
    { node => 2, code => 509, error => 'Timeout' },
    { node => 1, ping => 0 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },

);

ok $t->perform_request
    && $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && $t->perform_request,
    'One node throws Timeout, causing Timeout on other node';

done_testing;
