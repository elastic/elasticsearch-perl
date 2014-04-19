use Test::More;

BEGIN { use_ok('Search::Elasticsearch::Async') }

my ( $e, $p, $t );

isa_ok $e = Search::Elasticsearch::Async->new(),
    'Search::Elasticsearch::Client::Direct',
    "client";
isa_ok $t = $e->transport, 'Search::Elasticsearch::Transport::Async',
    "transport";
isa_ok $p = $t->cxn_pool, 'Search::Elasticsearch::CxnPool::Async::Static',
    "cxn_pool";
isa_ok $p->cxn_factory, 'Search::Elasticsearch::Cxn::Factory', "cxn_factory";
isa_ok $e->logger, 'Search::Elasticsearch::Logger::LogAny', "logger";

done_testing;

