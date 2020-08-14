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

my ( $error, $name );

$ENV{ES_VERSION} = '2_0';
my $es = do "es_async.pl" or die( $@ || $! );

my $b = $es->bulk_helper(
    on_fatal => sub {
        like shift(), qr/$error/, $name;
    }
);

$b->_serializer->_set_canonical;

## EMPTY

ok $b->add_action(), 'Empty add action';

## INDEX ACTIONS ##

ok $b->add_action(
    index => {
        index        => 'foo',
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
    index => {
        _index        => 'foo',
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

## CREATE ACTIONS ##

ok $b->add_action(
    create => {
        index        => 'foo',
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
    create => {
        _index        => 'foo',
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

## DELETE ACTIONS ##

ok $b->add_action(
    delete => {
        index        => 'foo',
        type         => 'bar',
        id           => 1,
        routing      => 1,
        parent       => 1,
        version      => 1,
        version_type => 'external',
    },
    delete => {
        _index        => 'foo',
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

## UPDATE ACTIONS ##

ok $b->add_action(
    update => {
        index         => 'foo',
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
    update => {
        index        => 'foo',
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
    update => {
        _index        => 'foo',
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
    update => {
        _index        => 'foo',
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
    update => {
        _index        => 'foo',
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
        detect_noop   => 1,
    },
    update => {
        _index             => 'foo',
        _type              => 'bar',
        _id                => 1,
        _routing           => 1,
        _parent            => 1,
        _timestamp         => 1380019061000,
        _ttl               => '10m',
        _version           => 1,
        _version_type      => 'external',
        upsert             => { counter => 0 },
        script             => '_ctx.source.counter+=incr',
        lang               => 'mvel',
        params             => { incr => 1 },
        detect_noop        => 1,
        _retry_on_conflict => 3,
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
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"detect_noop":1,"doc":{"foo":"bar"},"doc_as_upsert":1}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"_retry_on_conflict":3,"detect_noop":1,"lang":"mvel","params":{"incr":1},"script":"_ctx.source.counter+=incr","upsert":{"counter":0}}),
    ],
    "Update actions in buffer";

is $b->_buffer_size,  1393, "Update actions buffer size";
is $b->_buffer_count, 6,    "Update actions buffer count";

$b->clear_buffer;

## ERRORS ##
$error = "Unrecognised action";
$name  = 'Bad action';
$b->add_action( 'foo' => {} );

$error = "Missing <params>";
$name  = 'Missing params';
$b->add_action( 'index', 'bar' );

$error = "Missing .*<index>";
$name  = 'Missing index';
$b->add_action( index => { type => 't' } );

$error = "Missing .*<type>";
$name  = 'Missing type';
$b->add_action( index => { index => 'i' } );

$error = "Missing .*<source>";
$name  = 'Missing source';
$b->add_action( index => { index => 'i', type => 't' } );

$error = "Unknown params";
$name  = 'Unknown params';
$b->add_action(
    index => { index => 'i', type => 't', _source => {}, foo => 1 } );

done_testing;
