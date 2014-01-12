use Test::More;
use Test::Deep;
use Test::Exception;
use strict;
use warnings;
use Elasticsearch::Bulk;
use lib 't/lib';

my $es = do "es_sync.pl";

my $b = Elasticsearch::Bulk->new( es => $es, index => 'i', type => 't' );
my $s = $b->_serializer;
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
    'Index';

cmp_deeply $b->_buffer,
    [
    q({"index":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"}),
    q({"index":{"_id":2,"_index":"foo","_parent":2,"_routing":2,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Index in buffer";

is $b->_buffer_size,  336, "Index buffer size";
is $b->_buffer_count, 2,   "Index buffer count";

$b->clear_buffer;

## CREATE ##

ok $b->create(), 'Create empty';

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
    'Create';

cmp_deeply $b->_buffer,
    [
    q({"create":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"}),
    q({"create":{"_id":2,"_index":"foo","_parent":2,"_routing":2,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Create in buffer";

is $b->_buffer_size,  338, "Create buffer size";
is $b->_buffer_count, 2,   "Create buffer count";

$b->clear_buffer;

## CREATE DOCS##

ok $b->create_docs(), 'Create_docs empty';

ok $b->create_docs( { foo => 'bar' }, { foo => 'baz' } ), 'Create docs';

cmp_deeply $b->_buffer,
    [ q({"create":{}}), q({"foo":"bar"}), q({"create":{}}),
    q({"foo":"baz"}) ],
    "Create docs in buffer";

is $b->_buffer_size,  56, "Create docs buffer size";
is $b->_buffer_count, 2,  "Create docs buffer count";

$b->clear_buffer;

## DELETE ##
ok $b->delete(), 'Delete empty';

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
    'Delete';

cmp_deeply $b->_buffer,
    [
    q({"delete":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_type":"bar","_version":1,"_version_type":"external"}}),
    q({"delete":{"_id":2,"_index":"foo","_parent":2,"_routing":2,"_type":"bar","_version":1,"_version_type":"external"}}),
    ],
    "Delete in buffer";

is $b->_buffer_size,  230, "Delete buffer size";
is $b->_buffer_count, 2,   "Delete buffer count";

$b->clear_buffer;

## DELETE IDS ##
ok $b->delete_ids(), 'Delete IDs empty';

ok $b->delete_ids( 1, 2, 3 ), 'Delete IDs';

cmp_deeply $b->_buffer,
    [
    q({"delete":{"_id":1}}), q({"delete":{"_id":2}}),
    q({"delete":{"_id":3}}),
    ],
    "Delete IDs in buffer";

is $b->_buffer_size,  63, "Delete IDs buffer size";
is $b->_buffer_count, 3,  "Delete IDS buffer count";

$b->clear_buffer;

## UPDATE ACTIONS ##
ok $b->update(), 'Update empty';
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
    'Update';

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
    "Update in buffer";

is $b->_buffer_size,  892, "Update buffer size";
is $b->_buffer_count, 4,   "Update buffer count";

$b->clear_buffer;

done_testing;
