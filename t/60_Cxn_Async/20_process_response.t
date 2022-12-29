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
use Test::Deep;
use Search::Elasticsearch::Async;
use Search::Elasticsearch::Role::Cxn qw(PRODUCT_CHECK_HEADER PRODUCT_CHECK_VALUE);

our $PRODUCT_CHECK_VALUE = $Search::Elasticsearch::Role::Cxn::PRODUCT_CHECK_VALUE;
our $PRODUCT_CHECK_HEADER = $Search::Elasticsearch::Role::Cxn::PRODUCT_CHECK_HEADER;

my $c = Search::Elasticsearch::Async->new->transport->cxn_pool->cxns->[0];
ok $c->does('Search::Elasticsearch::Role::Cxn::Async'),
    'Does Search::Elasticsearch::Role::Cxn::Async';

my ( $code, $response );

### OK GET
( $code, $response )
    = $c->process_response( { method => 'GET', ignore => [] },
    200, "OK", '{"ok":1}', { 'content-type' => 'application/json', $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE } );

is $code, 200, "OK GET - code";
cmp_deeply $response, { ok => 1 }, "OK GET - body";

### OK GET - Text body
( $code, $response )
    = $c->process_response( { method => 'GET', ignore => [] },
    200, "OK", 'Foo', { 'content-type' => 'text/plain', $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE } );

is $code,             200,   "OK GET Text body - code";
cmp_deeply $response, 'Foo', "OK GET Text body - body";

### OK GET - Empty body
( $code, $response )
    = $c->process_response( { method => 'GET', ignore => [] }, 200, "OK",
    '', { $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE } );

is $code,             200, "OK GET Empty body - code";
cmp_deeply $response, '',  "OK GET Empty body - body";

### OK HEAD
( $code, $response )
    = $c->process_response( { method => 'HEAD', ignore => [] }, 200, "OK", '', { $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE });

is $code,     200, "OK HEAD - code";
is $response, 1,   "OK HEAD - body";

### Missing GET
throws_ok {
    $c->process_response(
        { method => 'GET', ignore => [] },
        404, "Missing",
        '{"error": "Something is missing"}',
        { 'content-type' => 'application/json', $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE }
    );
}
qr/Missing/, "Missing GET";

### Missing GET ignore
( $code, $response ) = $c->process_response(
    { method => 'GET', ignore => [404] },
    404, "Missing",
    '{"error": "Something is missing"}',
    { 'content-type' => 'application/json', $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE }
);

is $code,     404,   "Missing GET - code";
is $response, undef, "Missing GET - body";

### Missing HEAD
( $code, $response )
    = $c->process_response( { method => 'HEAD', ignore => [] },
    404, "Missing" );
is $code,     404,   "Missing HEAD - code";
is $response, undef, "Missing HEAD - body";

### Request error
throws_ok {
    $c->process_response(
        { method => 'GET', ignore => [] },
        400, "Request",
        '{"error":"error in body"}',
        { 'content-type' => 'application/json', $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE }
    );
}
qr/\[400\] error in body/, "Request error";

### Timeout error
throws_ok {
    $c->process_response( { method => 'GET', ignore => [] },
        509, "28: Timed out,read timeout" );
}
qr/Timeout/, "Timeout error";

done_testing;
