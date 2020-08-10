# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Test::Deep;
use Test::Exception;
use strict;
use warnings;
use lib 't/lib';

$ENV{ES_VERSION} = '7_0';
my $es = do "es_sync.pl" or die( $@ || $! );
my $b = $es->bulk_helper(
    index => 'i'
);
my $s = $b->_serializer;
$s->_set_canonical;

## INDEX ##

ok $b->index(), 'Empty index';

ok $b->index(
    {   index        => 'foo',
        id           => 1,
        pipeline     => 'foo',
        routing      => 1,
        parent       => 1,
        timestamp    => 1380019061000,
        ttl          => '10m',
        version      => 1,
        version_type => 'external',
        source       => { foo => 'bar' },
    },
    {   _index        => 'foo',
        _id           => 2,
        _routing      => 2,
        _parent       => 2,
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        source        => { foo => 'bar' },

    }
    ),
    'Index';

cmp_deeply $b->_buffer,
    [
    q({"index":{"_id":1,"_index":"foo","parent":1,"pipeline":"foo","routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"}),
    q({"index":{"_id":2,"_index":"foo","parent":2,"routing":2,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Index in buffer";

is $b->_buffer_size,  313, "Index buffer size";
is $b->_buffer_count, 2,   "Index buffer count";

$b->clear_buffer;

## CREATE ##

ok $b->create(), 'Create empty';

ok $b->create(
    {   index        => 'foo',
        id           => 1,
        routing      => 1,
        parent       => 1,
        pipeline     => 'foo',
        timestamp    => 1380019061000,
        ttl          => '10m',
        version      => 1,
        version_type => 'external',
        source       => { foo => 'bar' },
    },
    {   _index        => 'foo',
        _id           => 2,
        _routing      => 2,
        _parent       => 2,
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        source        => { foo => 'bar' },
    }
    ),
    'Create';

cmp_deeply $b->_buffer,
    [
    q({"create":{"_id":1,"_index":"foo","parent":1,"pipeline":"foo","routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"}),
    q({"create":{"_id":2,"_index":"foo","parent":2,"routing":2,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Create actions in buffer";

is $b->_buffer_size,  315, "Create actions buffer size";
is $b->_buffer_count, 2,   "Create actions buffer count";

$b->clear_buffer;

## CREATE DOCS##

ok $b->create_docs(), 'Create_docs empty';

ok $b->create_docs( { foo => 'bar' }, { foo => 'baz' } ), 'Create docs';

cmp_deeply $b->_buffer,
    [ q({"create":{}}), q({"foo":"bar"}), q({"create":{}}), q({"foo":"baz"}) ],
    "Create docs in buffer";

is $b->_buffer_size,  56, "Create docs buffer size";
is $b->_buffer_count, 2,  "Create docs buffer count";

$b->clear_buffer;

## DELETE ##
ok $b->delete(), 'Delete empty';

ok $b->delete(
    {   index        => 'foo',
        id           => 1,
        routing      => 1,
        parent       => 1,
        version      => 1,
        version_type => 'external',
    },
    {   _index       => 'foo',
        _id          => 2,
        _routing     => 2,
        _parent      => 2,
        _version     => 1,
        version_type => 'external',
    }
    ),
    'Delete';

cmp_deeply $b->_buffer,
    [
    q({"delete":{"_id":1,"_index":"foo","parent":1,"routing":1,"version":1,"version_type":"external"}}),
    q({"delete":{"_id":2,"_index":"foo","parent":2,"routing":2,"version":1,"version_type":"external"}}),
    ],
    "Delete actions in buffer";

is $b->_buffer_size,  194, "Delete actions buffer size";
is $b->_buffer_count, 2,   "Delete actions buffer count";

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
    {   index             => 'foo',
        id                => 1,
        routing           => 1,
        parent            => 1,
        timestamp         => 1380019061000,
        ttl               => '10m',
        version           => 1,
        version_type      => 'external',
        detect_noop       => 'true',
        _source           => 'true',
        _source_includes  => ['foo'],
        _source_excludes  => ['bar'],
        doc               => { foo => 'bar' },
        doc_as_upsert     => 1,
        fields            => ["*"],
        script            => 'ctx._source+=1',
        scripted_upsert   => 'true',
        retry_on_conflict => 3,
    },
    {   _index            => 'foo',
        _id               => 1,
        _routing          => 1,
        _parent           => 1,
        _timestamp        => 1380019061000,
        _ttl              => '10m',
        _version          => 1,
        _version_type     => 'external',
        detect_noop       => 'true',
        _source           => 'true',
        _source_includes  => ['foo'],
        _source_excludes  => ['bar'],
        doc               => { foo => 'bar' },
        doc_as_upsert     => 1,
        fields            => ["*"],
        script            => 'ctx._source+=1',
        scripted_upsert   => 'true',
        retry_on_conflict => 3,
    }
    ),
    'Update';

cmp_deeply $b->_buffer,
    [
    q({"update":{"_id":1,"_index":"foo","parent":1,"routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"_source":"true","_source_excludes":["bar"],"_source_includes":["foo"],"detect_noop":"true","doc":{"foo":"bar"},"doc_as_upsert":1,"fields":["*"],"retry_on_conflict":3,"script":"ctx._source+=1","scripted_upsert":"true"}),
    q({"update":{"_id":1,"_index":"foo","parent":1,"routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"_source":"true","_source_excludes":["bar"],"_source_includes":["foo"],"detect_noop":"true","doc":{"foo":"bar"},"doc_as_upsert":1,"fields":["*"],"retry_on_conflict":3,"script":"ctx._source+=1","scripted_upsert":"true"})
    ],
    "Update actions in buffer";

is $b->_buffer_size,  710, "Update actions buffer size";
is $b->_buffer_count, 2,   "Update actions buffer count";

$b->clear_buffer;

done_testing;
