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
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
use MockAsyncCxn qw(mock_sniff_client);

## Sniff all nodes fail

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, sniff => [ 'one', 'two' ] },
    { node => 3, code => 200, content => 1 },
    { node => 4, code => 509, error   => 'Cxn' },
    { node => 3, sniff => [], error => 'Cxn', code => 509 },
    { node => 4, sniff => [], error => 'Cxn', code => 509 },
    { node => 5, sniff => [], error => 'Cxn', code => 509 },
    { node => 6, sniff => [], error => 'Cxn', code => 509 },

    # throws NoNodes

    { node => 3, sniff => [], error => 'Cxn', code => 509 },
    { node => 4, sniff => [], error => 'Cxn', code => 509 },
    { node => 7, sniff => [], error => 'Cxn', code => 509 },
    { node => 8, sniff => [], error => 'Cxn', code => 509 },

    # throws NoNodes

    { node => 3, sniff => [ 'one', 'two' ] },
    { node => 4, sniff => [ 'one', 'two' ] },
    { node => 9,  code => 200, content => 1 },
    { node => 10, code => 200, content => 1 },
    { node => 9,  code => 200, content => 1 },
);

ok $t->perform_sync_request()
    && !eval { $t->perform_sync_request }
    && $@ =~ /NoNodes/
    && !eval { $t->perform_sync_request }
    && $@ =~ /NoNodes/
    && $t->perform_sync_request,
    'Sniff after all nodes fail';

done_testing;
