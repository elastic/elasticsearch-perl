use Test::More;
use Test::Deep;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_static_client);

our $t;

# good request
$t = mock_static_client(
    { nodes => ['one'] },                         #
    { node  => 1, ping => 1 },                    #
    { node  => 1, code => '200', content => 1 }
);

ok $t->perform_request, 'Simple request';

# Request error
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '404', error => 'NotFound' }
);

throws_ok { $t->perform_request } qr/Missing/, 'Request error';

# Timeout error
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '509', error => 'Timeout' },
    { node => 1, ping => 1 },
    { node => 1, code => '200', content => 1 }
);

throws_ok { $t->perform_request } qr/Timeout/, 'Timeout error';
ok $t->perform_request, 'Timeout resolved';

# Cxn error
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '509', error => 'Cxn' },
    { node => 1, ping => 1 },
    { node => 1, code => '200', content => 1 }
);

ok $t->perform_request, 'Retried connection error';

# NoNodes from failure
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '509', error => 'Cxn' },
    { node => 1, ping => 0 },
);

throws_ok { $t->perform_request } qr/NoNodes/, 'Cxn then bad ping';

# NoNodes reachable
$t = mock_static_client(
    { nodes => ['one'] },       #
    { node => 1, ping => 0 },
);

throws_ok { $t->perform_request } qr/NoNodes/, 'Initial bad ping';

done_testing;
