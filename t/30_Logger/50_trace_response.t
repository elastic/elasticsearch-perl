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

do './t/lib/LogCallback.pl' or die( $@ || $! );

ok my $e
    = Search::Elasticsearch->new( nodes => 'https://foo.bar:444/some/path' ),
    'Client';

isa_ok my $l = $e->logger, 'Search::Elasticsearch::Logger::LogAny', 'Logger';
my $c = $e->transport->cxn_pool->cxns->[0];
ok $c->does('Search::Elasticsearch::Role::Cxn'),
    'Does Search::Elasticsearch::Role::Cxn';

# No body

ok $l->trace_response( $c, 200, undef, 0.123 ), 'No body';

is $format, <<"RESPONSE", 'No body - format';
# Response: 200, Took: 123 ms
#\x20
RESPONSE

# Body

ok $l->trace_response( $c, 200, { foo => 'bar' }, 0.123 ), 'Body';
is $format, <<'RESPONSE', 'Body - format';
# Response: 200, Took: 123 ms
# {
#    "foo" : "bar"
# }
RESPONSE

done_testing;

