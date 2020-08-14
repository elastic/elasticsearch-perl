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
use Search::Elasticsearch;
use lib 't/lib';
use MockCxn qw(mock_sniff_client);

## Sniff when bad node timesout causing good node to timeout too

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, code => 200, content => 1 },
    { node => 3, code => 509, error   => 'Timeout' },

    # throws Timeout

    { node => 2, sniff => ['one'] },
    { node => 4, code  => 509, error => 'Timeout' },

    # throws Timeout

    { node => 4, sniff => ['one'] },
    { node => 5, code  => 200, content => 1 },

    # force sniff
    { node => 5, sniff => [ 'one', 'two' ] },
    { node => 6, code => 200, content => 1 },
    { node => 7, code => 200, content => 1 },
);

ok $t->perform_request()
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && $t->perform_request
    && $t->cxn_pool->schedule_check
    && $t->perform_request
    && $t->perform_request,
    'Sniff after both nodes timeout';

done_testing;
