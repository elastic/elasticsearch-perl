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

## Runaway nodes (ie wrong HTTP response codes signal node failure, instead of
## request failure)

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, code  => 200,     content => 1 },
    { node => 3, code  => 503,     error   => 'Unavailable' },
    { node => 2, sniff => [ 'one', 'two' ] },
    { node => 4, code  => 503,     error   => 'Unavailable' },

    # throw Unavailable: too many retries

    { node => 5, sniff => [ 'one', 'two' ] },
    { node => 6, code  => 503,     error => 'Unavailable' },
    { node => 7, sniff => [ 'one', 'two' ] },
    { node => 8, code  => 503,     error => 'Unavailable' },

    # throw Unavailable: too many retries

    { node => 9, sniff => [ 'one', 'two' ] },
    { node => 10, code => 200, content => 1 },
);

ok $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Unavailable/
    && !eval { $t->perform_request }
    && $@ =~ /Unavailable/
    && $t->perform_request,
    "Runaway nodes";

done_testing;
