use Test::More;
use Test::Deep;
use strict;
use warnings;
use lib 't/lib';

my $es = do "es_test_server.pl";

BEGIN { use_ok "Elasticsearch::Bulk" }

isa_ok my $b = Elasticsearch::Bulk->new( es => $es ), 'Elasticsearch::Bulk',
    'Bulk';

isa_ok my $s = $b->_serializer, 'Elasticsearch::Serializer::JSON',
    'Serializer';

$s->_set_canonical;

## INDEX ##

ok $b->index(), 'Empty index';

ok $b->index(
    {   index        => 'foo',
        type         => 'bar',
        id           => 1,
        routing      => 1,
        parent       => 1,
        timestamp    => 1380019061000,
        ttl          => '10m',
        version      => 1,
        version_type => 'external',
        source       => { foo => 'bar' },
    },
    {   _index        => 'foo',
        _type         => 'bar',
        _id           => 2,
        _routing      => 2,
        _parent       => 2,
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        _source       => { foo => 'bar' },
    }
    ),
    'Add index actions';

cmp_deeply $b->_buffer,
    [
    q({"index":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"}),
    q({"index":{"_id":2,"_index":"foo","_parent":2,"_routing":2,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Index actions in buffer";

is $b->_buffer_size,  336, "Index actions buffer size";
is $b->_buffer_count, 2,   "Index actions buffer count";

$b->clear_buffer;

## CREATE ##

ok $b->create(), 'Empty create';

ok $b->create(
    {   index        => 'foo',
        type         => 'bar',
        id           => 1,
        routing      => 1,
        parent       => 1,
        timestamp    => 1380019061000,
        ttl          => '10m',
        version      => 1,
        version_type => 'external',
        source       => { foo => 'bar' },
    },
    {   _index        => 'foo',
        _type         => 'bar',
        _id           => 2,
        _routing      => 2,
        _parent       => 2,
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        _source       => { foo => 'bar' },
    }
    ),
    'Add create actions';

cmp_deeply $b->_buffer,
    [
    q({"create":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"}),
    q({"create":{"_id":2,"_index":"foo","_parent":2,"_routing":2,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Create actions in buffer";

is $b->_buffer_size,  338, "Create actions buffer size";
is $b->_buffer_count, 2,   "Create actions buffer count";

$b->clear_buffer;

## CREATE_DOCS  ##

ok $b->create_docs(), 'Empty create_docs';

ok $b->create_docs( { foo => 'bar' }, { foo => 'baz' } ), 'create_docs';

cmp_deeply $b->_buffer,
    [ q({"create":{}}), q({"foo":"bar"}), q({"create":{}}),
    q({"foo":"baz"}) ],
    "create_docs in buffer";

is $b->_buffer_size,  56, "create_docs buffer size";
is $b->_buffer_count, 2,  "create_docs buffer count";

$b->clear_buffer;

## DELETE ##

ok $b->delete(), 'Empty delete';

ok $b->delete(
    {   index        => 'foo',
        type         => 'bar',
        id           => 1,
        routing      => 1,
        parent       => 1,
        version      => 1,
        version_type => 'external',
    },
    {   _index        => 'foo',
        _type         => 'bar',
        _id           => 2,
        _routing      => 2,
        _parent       => 2,
        _version      => 1,
        _version_type => 'external',
    }
    ),
    'Add delete actions';

cmp_deeply $b->_buffer,
    [
    q({"delete":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_type":"bar","_version":1,"_version_type":"external"}}),
    q({"delete":{"_id":2,"_index":"foo","_parent":2,"_routing":2,"_type":"bar","_version":1,"_version_type":"external"}}),
    ],
    "Delete actions in buffer";

is $b->_buffer_size,  230, "Delete actions buffer size";
is $b->_buffer_count, 2,   "Delete actions buffer count";

$b->clear_buffer;

## DELETE IDS ##

ok $b->delete_ids(), 'Empty delete_ids';

ok $b->delete_ids( 1, 2 ), 'delete_ids';

cmp_deeply $b->_buffer,
    [ q({"delete":{"_id":1}}), q({"delete":{"_id":2}}), ],
    "delete_ids in buffer";

is $b->_buffer_size,  42, "delete_ids buffer size";
is $b->_buffer_count, 2,  "delete_ids buffer count";

$b->clear_buffer;

## UPDATE ##

ok $b->update(), 'Empty update';

ok $b->update(
    {   index         => 'foo',
        type          => 'bar',
        id            => 1,
        routing       => 1,
        parent        => 1,
        timestamp     => 1380019061000,
        ttl           => '10m',
        version       => 1,
        version_type  => 'external',
        doc           => { foo => 'bar' },
        doc_as_upsert => 1,
    },
    {   index        => 'foo',
        type         => 'bar',
        id           => 1,
        routing      => 1,
        parent       => 1,
        timestamp    => 1380019061000,
        ttl          => '10m',
        version      => 1,
        version_type => 'external',
        upsert       => { counter => 0 },
        script       => '_ctx.source.counter+=incr',
        lang         => 'mvel',
        params       => { incr => 1 },
    },
    {   _index        => 'foo',
        _type         => 'bar',
        _id           => 1,
        _routing      => 1,
        _parent       => 1,
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        doc           => { foo => 'bar' },
        doc_as_upsert => 1,
    },
    {   _index        => 'foo',
        _type         => 'bar',
        _id           => 1,
        _routing      => 1,
        _parent       => 1,
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        upsert        => { counter => 0 },
        script        => '_ctx.source.counter+=incr',
        lang          => 'mvel',
        params        => { incr => 1 },
    },
    ),
    'Add update actions';

cmp_deeply $b->_buffer,
    [
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"doc":{"foo":"bar"},"doc_as_upsert":1}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"lang":"mvel","params":{"incr":1},"script":"_ctx.source.counter+=incr","upsert":{"counter":0}}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"doc":{"foo":"bar"},"doc_as_upsert":1}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"lang":"mvel","params":{"incr":1},"script":"_ctx.source.counter+=incr","upsert":{"counter":0}}),
    ],
    "Update actions in buffer";

is $b->_buffer_size,  892, "Update actions buffer size";
is $b->_buffer_count, 4,   "Update actions buffer count";

$b->clear_buffer;

done_testing;
