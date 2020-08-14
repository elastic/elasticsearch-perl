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
use AE;

use strict;
use warnings;
use lib 't/lib';
use Log::Any::Adapter;

$ENV{ES_VERSION} = '2_0';
$ENV{ES}           = '10.255.255.1:9200';
$ENV{ES_SKIP_PING} = 1;
$ENV{ES_CXN_POOL}  = 'Async::Static';

my $es = do "es_async.pl" or die( $@ || $! );
my $error;
my $b = $es->bulk_helper( index => 'foo', type => 'bar' );
$b->create_docs( { foo => 'bar' } );

# Check that the buffer is not cleared on a NoNodes exception

is $b->_buffer_count, 1, "Buffer count pre-flush";

wait_for(
    $b->flush->catch(
        sub {
            my $error = shift;
            isa_ok $error, 'Search::Elasticsearch::Error::NoNodes';
        }
    )
);

is $b->_buffer_count, 1, "Buffer count post-flush";

done_testing;
