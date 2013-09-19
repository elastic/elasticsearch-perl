use Test::More;
use Test::Deep;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn;

our $t;

# good request
$t = mock_client(
    { ping => 1 },                              #
    { code => '200', content => '{"ok":1}' }    #
);

cmp_deeply $t->perform_request( { path => '/' } ), { ok => 1 },
    'Simple request';

# Request error
$t = mock_client(
    { ping => 1 },
    {   code    => '404',
        content => '{"error":"Foo missing"}',
        error   => 'NotFound'
    }
);

throws_ok { $t->perform_request( { path => '/_foo' } ) }
qr/Missing.*Foo missing/, 'Request error';

# Timeout error
$t = mock_client(
    { ping => 1 },
    { code => '509', error => 'Timeout' },
    { ping => 1 },
    { code => '200', content => '{"ok":1}' }    #
);

throws_ok { $t->perform_request( { path => '/' } ) } qr/Timeout/,
    'Timeout error';
cmp_deeply $t->perform_request( { path => '/' } ), { ok => 1 },
    'Timeout resolved';

# Cxn error
$t = mock_client(
    { ping => 1 },
    { code => '509', error => 'Cxn' },
    { ping => 1 },
    { code => '200', content => '{"ok":1}' }    #
);

cmp_deeply $t->perform_request( { path => '/' } ), { ok => 1 },
    'Retried connection error';

# NoNodes from failure
$t = mock_client(
    { ping => 1 },
    { code => '509', error => 'Cxn' },
    { ping => 0 },                              # this node
    { ping => 0 },                              # seed node
);

throws_ok { $t->perform_request( { path => '/' } ) } qr/NoNodes/,
    'Cxn then bad ping';

# NoNodes reachable
$t = mock_client(
    { ping => 0 },                              # this node
    { ping => 0 }                               # seed node
);
throws_ok { $t->perform_request( { path => '/' } ) } qr/NoNodes/,
    'Initial bad ping';

done_testing;

#===================================
sub mock_client {
#===================================
    return Elasticsearch->new(
        cxn            => '+Elasticsearch::MockCxn',
        mock_responses => \@_
    )->transport;
}

