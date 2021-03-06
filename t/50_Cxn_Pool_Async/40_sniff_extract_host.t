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
use Search::Elasticsearch::Async;

my $pool
    = Search::Elasticsearch::Async->new( cxn_pool => 'Async::Sniff' )
    ->transport->cxn_pool;

is $pool->_extract_host('127.0.0.1:9200'), '127.0.0.1:9200', "IP";

is $pool->_extract_host('myhost/127.0.0.1:9200'), '127.0.0.1:9200', "Host/IP";

is $pool->_extract_host('inet[127.0.0.1:9200]'), '127.0.0.1:9200', "inet[IP]";

is $pool->_extract_host('inet[myhost/127.0.0.1:9200]'), '127.0.0.1:9200',
    "inet[Host/IP]";

is $pool->_extract_host('inet[/127.0.0.1:9200]'), '127.0.0.1:9200',
    "inet[/IP]";

ok !$pool->_extract_host(), "Undefined";

done_testing;
