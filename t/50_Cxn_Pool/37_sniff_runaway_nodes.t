use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_sniff_client);

## Runaway nodes (ie wrong HTTP response codes signal node failure, instead of
## request failure)

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, code  => 200,     content => 1 },
    { node => 3, code  => 503,     error   => 'Unavailable' },
    { node => 2, sniff => [ 'one', 'two' ] },
    { node => 4, code  => 503,     error   => 'Unavailable' },

    # throw Unavailable: too many retries

    { node => 5, sniff => [ 'one', 'two' ] },
    { node => 6, code  => 503,     error => 'Unavailable' },
    { node => 7, sniff => [ 'one', 'two' ] },
    { node => 8, code  => 503,     error => 'Unavailable' },

    # throw Unavailable: too many retries

    { node => 9, sniff => [ 'one', 'two' ] },
    { node => 10, code => 200, content => 1 },
);

ok $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Unavailable/
    && !eval { $t->perform_request }
    && $@ =~ /Unavailable/
    && $t->perform_request,
    "Runaway nodes";

done_testing;
