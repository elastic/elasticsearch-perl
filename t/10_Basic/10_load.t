use Test::More;

BEGIN { use_ok('Elasticsearch') }

my ( $e, $p, $t );

isa_ok $e = Elasticsearch->new(), 'Elasticsearch::Client::Direct', "client";
isa_ok $t = $e->transport, 'Elasticsearch::Transport', "transport";
isa_ok $t->serializer, 'Elasticsearch::Serializer::JSON', "serializer";
isa_ok $p = $t->cxn_pool, 'Elasticsearch::CxnPool::Static', "cxn_pool";
isa_ok $p->cxn_factory, 'Elasticsearch::Cxn::Factory',   "cxn_factory";
isa_ok $e->logger,      'Elasticsearch::Logger::LogAny', "logger";

done_testing;

