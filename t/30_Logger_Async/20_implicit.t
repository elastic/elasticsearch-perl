use Test::More;
use Search::Elasticsearch::Async;

use Log::Any::Adapter;

Log::Any::Adapter->set( { category => 'elasticsearch.event' }, 'Stdout' );
Log::Any::Adapter->set( { category => 'elasticsearch.trace' }, 'Stderr' );

# default

isa_ok my $l = Search::Elasticsearch::Async->new->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Default Logger';

isa_ok $l->log_handle->adapter, 'Log::Any::Adapter::Stdout',
    'Default - Log to Stdout';
isa_ok $l->trace_handle->adapter, 'Log::Any::Adapter::Stderr',
    'Default - Trace to Stderr';

# override

isa_ok $l = Search::Elasticsearch::Async->new(
    log_to   => 'Stderr',
    trace_to => 'Stdout'
    )->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Override Logger';

isa_ok $l->log_handle->adapter, 'Log::Any::Adapter::Stderr',
    'Override - Log to Stderr';
isa_ok $l->trace_handle->adapter, 'Log::Any::Adapter::Stdout',
    'Override - Trace to Stdout';

done_testing;
