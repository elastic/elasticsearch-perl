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
        pipeline     => 'foo',
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
        source        => { foo => 'bar' },

    }
    ),
    'Add index actions';

cmp_deeply $b->_buffer,
    [
    q({"index":{"_id":1,"_index":"foo","_type":"bar","parent":1,"pipeline":"foo","routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"}),
    q({"index":{"_id":2,"_index":"foo","_type":"bar","parent":2,"routing":2,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"foo":"bar"})
    ],
    "Index actions in buffer";

is $b->_buffer_size,  341, "Index actions buffer size";
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
        pipeline     => 'foo',
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
        source        => { foo => 'bar' },
    }
    ),
    'Add create actions';

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
        _index       => 'foo',
        _type        => 'bar',
        _id          => 2,
        _routing     => 2,
        _parent      => 2,
        _version     => 1,
        version_type => 'external',
    }
    ),
    'Add delete actions';

cmp_deeply $b->_buffer,
    [
    q({"delete":{"_id":1,"_index":"foo","_type":"bar","parent":1,"routing":1,"version":1,"version_type":"external"}}),
    q({"delete":{"_id":2,"_index":"foo","_type":"bar","parent":2,"routing":2,"version":1,"version_type":"external"}}),
    ],
    "Delete actions in buffer";

is $b->_buffer_size,  222, "Delete actions buffer size";
is $b->_buffer_count, 2,   "Delete actions buffer count";

$b->clear_buffer;

## UPDATE ACTIONS ##

ok $b->add_action(
    update => {
        index           => 'foo',
        type            => 'bar',
        id              => 1,
        routing         => 1,
        parent          => 1,
        timestamp       => 1380019061000,
        ttl             => '10m',
        version         => 1,
        version_type    => 'external',
        detect_noop     => 'true',
        _source         => 'true',
        _source_include => 'foo',
        _source_exclude => 'bar',
        doc             => { foo => 'bar' },
        doc_as_upsert   => 1,
        fields          => ["*"],
        script          => 'ctx._source+=1',
        scripted_upsert => 'true'

    },
    update => {
        _index          => 'foo',
        _type           => 'bar',
        _id             => 1,
        _routing        => 1,
        _parent         => 1,
        _timestamp      => 1380019061000,
        _ttl            => '10m',
        _version        => 1,
        _version_type   => 'external',
        detect_noop     => 'true',
        _source         => 'true',
        _source_include => 'foo',
        _source_exclude => 'bar',
        doc             => { foo => 'bar' },
        doc_as_upsert   => 1,
        fields          => ["*"],
        script          => 'ctx._source+=1',
        scripted_upsert => 'true'

    }
    ),
    'Add update actions';

cmp_deeply $b->_buffer,
    [
    q({"update":{"_id":1,"_index":"foo","_type":"bar","parent":1,"routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"_source":"true","_source_exclude":"bar","_source_include":"foo","detect_noop":"true","doc":{"foo":"bar"},"doc_as_upsert":1,"fields":["*"],"script":"ctx._source+=1","scripted_upsert":"true"}),
    q({"update":{"_id":1,"_index":"foo","_type":"bar","parent":1,"routing":1,"timestamp":1380019061000,"ttl":"10m","version":1,"version_type":"external"}}),
    q({"_source":"true","_source_exclude":"bar","_source_include":"foo","detect_noop":"true","doc":{"foo":"bar"},"doc_as_upsert":1,"fields":["*"],"script":"ctx._source+=1","scripted_upsert":"true"})
    ],
    "Update actions in buffer";

is $b->_buffer_size,  682, "Update actions buffer size";
is $b->_buffer_count, 2,   "Update actions buffer count";

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
        index => { index => 'i', type => 't', source => {}, foo => 1 } );
}
qr/Unknown params/, 'Unknown params';

done_testing;
