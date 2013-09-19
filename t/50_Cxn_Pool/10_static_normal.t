use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn;

## Both nodes respond - check ping before first use

my $t = mock_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, code => 200, content => 1 },
);

ok $t->perform_request()
    && $t->perform_request
    && $t->perform_request
    && $t->perform_request,
    'Ping before first use';

done_testing;

#===================================
sub mock_client {
#===================================
    my $params = shift;
    return Elasticsearch->new(
        cxn            => '+Elasticsearch::MockCxn',
        mock_responses => \@_,
        %$params,
    )->transport;
}
