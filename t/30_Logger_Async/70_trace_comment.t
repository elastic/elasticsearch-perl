use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
do 'LogCallback.pl';
our $format;

ok my $e
    = Search::Elasticsearch::Async->new(
    nodes => 'https://foo.bar:444/some/path' ),
    'Client';

isa_ok my $l = $e->logger, 'Search::Elasticsearch::Logger::LogAny', 'Logger';
my $c = $e->transport->cxn_pool->cxns->[0];
ok $c->does('Search::Elasticsearch::Role::Cxn'),
    'Does Search::Elasticsearch::Role::Cxn';

ok $l->trace_comment("The quick fox\njumped"), 'Comment';

is $format, <<"COMMENT", 'Comment - format';
# *** The quick fox
# *** jumped
COMMENT

done_testing;

