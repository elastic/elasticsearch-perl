use Test::More;
use Test::Deep;
use Test::Exception;
use strict;
use warnings;
use lib 't/lib';

$ENV{ES_VERSION} = '5_0';
my $es = do "es_sync.pl" or die( $@ || $! );
my $b = $es->bulk_helper;

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
        pipeline     => 'foobar',
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
        _pipeline     => 'foobar',
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
    q({"index":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"}),
    q({"index":{"_id":2,"_index":"foo","_parent":2,"_pipeline":"foobar","_routing":2,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Index actions in buffer";

is $b->_buffer_size,  378, "Index actions buffer size";
is $b->_buffer_count, 2,   "Index actions buffer count";

$b->clear_buffer;

# TODO RCL create tests for pipeline in all of the following actions too

## CREATE ACTIONS ##

ok $b->add_action(
    create => {
        index        => 'foo',
        type         => 'bar',
        id           => 1,
        routing      => 1,
        parent       => 1,
        pipeline     => 'foobar',
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
        _pipeline     => 'foobar',
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
    q({"create":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"}),
    q({"create":{"_id":2,"_index":"foo","_parent":2,"_pipeline":"foobar","_routing":2,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Create actions in buffer";

is $b->_buffer_size,  380, "Create actions buffer size";
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
        pipeline     => 'foobar',
        version      => 1,
        version_type => 'external',
    },
    delete => {
        _index        => 'foo',
        _type         => 'bar',
        _id           => 2,
        _routing      => 2,
        _parent       => 2,
        _pipeline     => 'foobar',
        _version      => 1,
        _version_type => 'external',
    }
    ),
    'Add delete actions';

cmp_deeply $b->_buffer,
    [
    q({"delete":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_type":"bar","_version":1,"_version_type":"external"}}),
    q({"delete":{"_id":2,"_index":"foo","_parent":2,"_pipeline":"foobar","_routing":2,"_type":"bar","_version":1,"_version_type":"external"}}),
    ],
    "Delete actions in buffer";

is $b->_buffer_size,  272, "Delete actions buffer size";
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
        pipeline     => 'foobar',
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
        pipeline     => 'foobar',
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
        _pipeline     => 'foobar',
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
        _pipeline     => 'foobar',
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
        _pipeline     => 'foobar',
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        doc           => { foo => 'bar' },
        doc_as_upsert => 1,
        detect_noop   => 1,
    },
    update => {
        _index        => 'foo',
        _type         => 'bar',
        _id           => 1,
        _routing      => 1,
        _parent       => 1,
        _pipeline     => 'foobar',
        _timestamp    => 1380019061000,
        _ttl          => '10m',
        _version      => 1,
        _version_type => 'external',
        upsert        => { counter => 0 },
        script        => '_ctx.source.counter+=incr',
        lang          => 'mvel',
        params        => { incr => 1 },
        detect_noop   => 1,
    },
    ),
    'Add update actions';

cmp_deeply $b->_buffer,
    [
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"doc":{"foo":"bar"},"doc_as_upsert":1}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"lang":"mvel","params":{"incr":1},"script":"_ctx.source.counter+=incr","upsert":{"counter":0}}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"doc":{"foo":"bar"},"doc_as_upsert":1}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"lang":"mvel","params":{"incr":1},"script":"_ctx.source.counter+=incr","upsert":{"counter":0}}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"detect_noop":1,"doc":{"foo":"bar"},"doc_as_upsert":1}),
    q({"update":{"_id":1,"_index":"foo","_parent":1,"_pipeline":"foobar","_routing":1,"_timestamp":1380019061000,"_ttl":"10m","_type":"bar","_version":1,"_version_type":"external"}}),
    q({"detect_noop":1,"lang":"mvel","params":{"incr":1},"script":"_ctx.source.counter+=incr","upsert":{"counter":0}}),
    ],
    "Update actions in buffer";

is $b->_buffer_size,  1496, "Update actions buffer size";
is $b->_buffer_count, 6,    "Update actions buffer count";

$b->clear_buffer;

## ERRORS ##
throws_ok { $b->add_action( 'foo' => {} ) } qr/Unrecognised action/,
    'Bad action';

throws_ok { $b->add_action( 'index', 'bar' ) } qr/Missing <params>/,
    'Missing params';

throws_ok { $b->add_action( index => { type => 't' } ) }
qr/Missing .*<index>/, 'Missing index';
throws_ok { $b->add_action( index => { index => 'i' } ) }
qr/Missing .*<type>/, 'Missing type';
throws_ok { $b->add_action( index => { index => 'i', type => 't' } ) }
qr/Missing <source>/, 'Missing source';

throws_ok {
    $b->add_action(
        index => { index => 'i', type => 't', _source => {}, foo => 1 } );
}
qr/Unknown params/, 'Unknown params';

done_testing;
