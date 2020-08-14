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
use Log::Any::Adapter;

$ENV{ES_VERSION} = '2_0';
$ENV{ES}           = '10.255.255.1:9200';
$ENV{ES_SKIP_PING} = 1;
$ENV{ES_CXN_POOL}  = 'Static';
$ENV{ES_TIMEOUT}   = 1;

my $es = do "es_sync.pl" or die( $@ || $! );
SKIP: {
    skip
        "IO::Socket::IP doesn't respect timeout: https://rt.cpan.org/Ticket/Display.html?id=103878",
        3
        if $es->transport->cxn_pool->cxn_factory->cxn_class eq
        'Search::Elasticsearch::Cxn::HTTPTiny'
        && $^V =~ /^v5.2\d/;

    # Check that the buffer is not cleared on a NoNodes exception

    my $b = $es->bulk_helper( index => 'foo', type => 'bar' );
    $b->create_docs( { foo => 'bar' } );

    is $b->_buffer_count, 1, "Buffer count pre-flush";
    throws_ok { $b->flush } 'Search::Elasticsearch::Error::NoNodes';
    is $b->_buffer_count, 1, "Buffer count post-flush";

}

done_testing;
