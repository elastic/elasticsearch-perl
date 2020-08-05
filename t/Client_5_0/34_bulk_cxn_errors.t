# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Test::Deep;
use Test::Exception;

use strict;
use warnings;
use lib 't/lib';
use Log::Any::Adapter;

$ENV{ES_VERSION}   = '5_0';
$ENV{ES}           = '10.255.255.1:9200';
$ENV{ES_SKIP_PING} = 1;
$ENV{ES_CXN_POOL}  = 'Static';
$ENV{ES_TIMEOUT}   = 1;

my $es = do "es_sync.pl" or die( $@ || $! );

# Check that the buffer is not cleared on a NoNodes exception

my $b = $es->bulk_helper( index => 'foo', type => 'bar' );
$b->create_docs( { foo => 'bar' } );

is $b->_buffer_count, 1, "Buffer count pre-flush";
throws_ok { $b->flush } 'Search::Elasticsearch::Error::NoNodes';
is $b->_buffer_count, 1, "Buffer count post-flush";

done_testing;
