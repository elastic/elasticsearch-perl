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
use MockCxn qw(mock_static_client);

## One node fails with a Timeout error, then rejoins

my $t = mock_static_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, code => 509, error => 'Timeout' },
    { node => 2, ping => 1 },
    { node => 2, code => 200, content => 1 },
    { node => 1, ping => 1 },
    { node => 1, code => 200, content => 1 },

);

ok $t->perform_request
    && $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Timeout/
    && $t->perform_request,
    'One node throws Timeout then recovers';

done_testing;

