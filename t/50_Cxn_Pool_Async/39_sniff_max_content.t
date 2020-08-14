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

## Dynamic max content length

my $response = <<RESPONSE;
{
    "nodes": {
        "one": {
            "http_address": "inet[/one]",
            "http": {
                "max_content_length_in_bytes": 200
            }
        },
        "two": {
            "http_address": "inet[/two]",
            "http": {
                "max_content_length_in_bytes": 509
            }
        },
        "three": {
            "http_address": "inet[/two]"
        }
    }
}
RESPONSE

my $t = mock_sniff_client(
    { nodes => ['one'] },
    { node  => 1, code => 200, content => $response },
    { node  => 2, code => 200, content => 1 },
);

$t->perform_sync_request
    && $t->cxn_pool->next_cxn->then(
    sub {
        is shift()->max_content_length, 200, "Dynamic max content length";
    }
    );

$t = mock_sniff_client(
    { nodes => ['one'], max_content_length => 1000 },
    { node => 1, code => 200, content => $response },
    { node => 2, code => 200, content => 1 },
);

$t->perform_sync_request
    && $t->cxn_pool->next_cxn->then(
    sub {
        is shift()->max_content_length, 1000, "Dynamic max content length";
    }
    );

done_testing;
