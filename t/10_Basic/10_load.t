use Test::More;

BEGIN { use_ok('Search::Elasticsearch') }

my ( $e, $p, $t );

isa_ok $e = Search::Elasticsearch->new(),
    'Search::Elasticsearch::Client::Direct', "client";
isa_ok $t = $e->transport, 'Search::Elasticsearch::Transport', "transport";
isa_ok $t->serializer, 'Search::Elasticsearch::Serializer::JSON',
    "serializer";
isa_ok $p = $t->cxn_pool, 'Search::Elasticsearch::CxnPool::Static',
    "cxn_pool";
isa_ok $p->cxn_factory, 'Search::Elasticsearch::Cxn::Factory', "cxn_factory";
isa_ok $e->logger, 'Search::Elasticsearch::Logger::LogAny', "logger";

done_testing;

