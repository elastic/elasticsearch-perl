use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
do 'LogCallback.pl';

isa_ok my $e
    = Search::Elasticsearch::Async->new( nodes => 'https://foo.bar:444/some/path' ),
    'Search::Elasticsearch::Client::Direct',
    'Client';

isa_ok my $l = $e->logger, 'Search::Elasticsearch::Logger::LogAny', 'Logger';
my $c = $e->transport->cxn_pool->cxns->[0];
ok $c->does('Search::Elasticsearch::Role::Cxn'), 'Does Search::Elasticsearch::Role::Cxn';

# No body

ok $l->trace_error( $c,
    Search::Elasticsearch::Error->new( 'Missing', "Foo missing", { code => 404 } ) ),
    'No body';

is $format, <<"RESPONSE", 'No body - format';
# ERROR: Search::Elasticsearch::Error::Missing Foo missing
#\x20
RESPONSE

# Body

ok $l->trace_error(
    $c,
    Search::Elasticsearch::Error->new(
        'Missing', "Foo missing", { code => 404, body => { foo => 'bar' } }
    )
    ),
    'Body';

is $format, <<"RESPONSE", 'Body - format';
# ERROR: Search::Elasticsearch::Error::Missing Foo missing
# {
#    "foo" : "bar"
# }
RESPONSE

done_testing;

