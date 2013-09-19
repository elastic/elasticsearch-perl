use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_static_client);

## Runaway nodes (ie wrong HTTP response codes signal node failure, instead of
## request failure)

my $t = mock_static_client(
    { nodes => 'one' },

    { ping => 1 },
    { code => 200, content => 1 },
    { code => 503, error => 'NotReady' },
    { ping => 1 },
    { code => 503, error => 'NotReady' },

    # throw Internal: too many retries

    { ping => 1 },
    { code => 503, error => 'NotReady' },
    { ping => 1 },
    { code => 503, error => 'NotReady' },

    # throw Internal: too many retries

);

ok $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Retried request/
    && !eval { $t->perform_request }
    && $@ =~ /Retried request/,
    "Runaway nodes";

done_testing;
