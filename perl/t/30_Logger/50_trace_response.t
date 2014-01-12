use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
do 'LogCallback.pl';

isa_ok my $e = Elasticsearch->new( nodes => 'https://foo.bar:444/some/path' ),
    'Elasticsearch::Client::Direct',
    'Client';

isa_ok my $l = $e->logger, 'Elasticsearch::Logger::LogAny', 'Logger';
my $c = $e->transport->cxn_pool->cxns->[0];
ok $c->does('Elasticsearch::Role::Cxn'), 'Does Elasticsearch::Role::Cxn';

# No body

ok $l->trace_response( $c, 200, undef, 0.123 ), 'No body';

is $format, <<"RESPONSE", 'No body - format';
# Response: 200, Took: 123 ms
#\x20
RESPONSE

# Body

ok $l->trace_response( $c, 200, { foo => 'bar' }, 0.123 ), 'Body';
is $format, <<'RESPONSE', 'Body - format';
# Response: 200, Took: 123 ms
# {
#    "foo" : "bar"
# }
RESPONSE

done_testing;

