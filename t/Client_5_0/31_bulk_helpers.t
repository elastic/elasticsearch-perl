# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

use Test::More;
use Test::Deep;
use Test::Exception;
use strict;
use warnings;
use lib 't/lib';

$ENV{ES_VERSION} = '5_0';
my $es = do "es_sync.pl" or die( $@ || $! );
my $b = $es->bulk_helper(
    index => 'i',
    type  => 't'
);
my $s = $b->_serializer;
$s->_set_canonical;

## INDEX ##

ok $b->index(), 'Empty index';

ok $b->index(
    {   index        => 'foo',
        type         => 'bar',
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
        _type         => 'bar',
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
    q({"index":{"_id":1,"_index":"foo","_type":"bar","parent":1,"pipeline":"foo","routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"}),
    q({"index":{"_id":2,"_index":"foo","_type":"bar","parent":2,"routing":2,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Index in buffer";

is $b->_buffer_size,  341, "Index buffer size";
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
        pipeline     => 'foo',
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
        source        => { foo => 'bar' },
    }
    ),
    'Create';

cmp_deeply $b->_buffer,
    [
    q({"create":{"_id":1,"_index":"foo","_type":"bar","parent":1,"pipeline":"foo","routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"}),
    q({"create":{"_id":2,"_index":"foo","_type":"bar","parent":2,"routing":2,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Create actions in buffer";

is $b->_buffer_size,  343, "Create actions buffer size";
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
        type         => 'bar',
        id           => 1,
        routing      => 1,
        parent       => 1,
        version      => 1,
        version_type => 'external',
    },
    {   _index       => 'foo',
        _type        => 'bar',
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
    q({"delete":{"_id":1,"_index":"foo","_type":"bar","parent":1,"routing":1,"version":1,"version_type":"external"}}),
    q({"delete":{"_id":2,"_index":"foo","_type":"bar","parent":2,"routing":2,"version":1,"version_type":"external"}}),
    ],
    "Delete actions in buffer";

is $b->_buffer_size,  222, "Delete actions buffer size";
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
    {   index              => 'foo',
        type               => 'bar',
        id                 => 1,
        routing            => 1,
        parent             => 1,
        timestamp          => 1380019061000,
        ttl                => '10m',
        version            => 1,
        version_type       => 'external',
        detect_noop        => 'true',
        _source            => 'true',
        _source_include    => 'foo',
        _source_exclude    => 'bar',
        doc                => { foo => 'bar' },
        doc_as_upsert      => 1,
        fields             => ["*"],
        script             => 'ctx._source+=1',
        scripted_upsert    => 'true',
        _retry_on_conflict => 3,
    },
    {   _index             => 'foo',
        _type              => 'bar',
        _id                => 1,
        _routing           => 1,
        _parent            => 1,
        _timestamp         => 1380019061000,
        _ttl               => '10m',
        _version           => 1,
        _version_type      => 'external',
        detect_noop        => 'true',
        _source            => 'true',
        _source_include    => 'foo',
        _source_exclude    => 'bar',
        doc                => { foo => 'bar' },
        doc_as_upsert      => 1,
        fields             => ["*"],
        script             => 'ctx._source+=1',
        scripted_upsert    => 'true',
        _retry_on_conflict => 3,
    }
    ),
    'Update';

cmp_deeply $b->_buffer,
    [
    q({"update":{"_id":1,"_index":"foo","_type":"bar","parent":1,"routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"_retry_on_conflict":3,"_source":"true","_source_exclude":"bar","_source_include":"foo","detect_noop":"true","doc":{"foo":"bar"},"doc_as_upsert":1,"fields":["*"],"script":"ctx._source+=1","scripted_upsert":"true"}),
    q({"update":{"_id":1,"_index":"foo","_type":"bar","parent":1,"routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"_retry_on_conflict":3,"_source":"true","_source_exclude":"bar","_source_include":"foo","detect_noop":"true","doc":{"foo":"bar"},"doc_as_upsert":1,"fields":["*"],"script":"ctx._source+=1","scripted_upsert":"true"})
    ],
    "Update actions in buffer";

is $b->_buffer_size,  728, "Update actions buffer size";
is $b->_buffer_count, 2,   "Update actions buffer count";

$b->clear_buffer;

done_testing;
