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

#! perl
use Test::More;
use Test::Deep;
use Test::Exception;

use strict;
use warnings;
use lib 't/lib';

our $Throws_SSL;

unless ( $ENV{ES_SSL} ) {
    plan skip_all => "$ENV{ES_CXN} - No https server specified in ES_SSL";
    exit;
}

unless ( $ENV{ES_USERINFO} ) {
    plan skip_all => "$ENV{ES_CXN} - No user/pass specified in ES_USERINFO";
    exit;
}

unless ( $ENV{ES_CA_PATH} ) {
    plan skip_all => "$ENV{ES_CXN} - No cacert specified in ES_CA_PATH";
    exit;
}

$ENV{ES}           = $ENV{ES_SSL};
$ENV{ES_SKIP_PING} = 1;

our %Auth = ( use_https => 1, userinfo => $ENV{ES_USERINFO} );

# Test https connection with correct auth, without cacert
$ENV{ES_CXN_POOL} = 'Static';
my $es = do "es_sync.pl" or die( $@ || $! );

ok $es->cluster->health,
    "$ENV{ES_CXN} - Non-cert HTTPS with auth, cxn static";

$ENV{ES_CXN_POOL} = 'Sniff';
$es = do "es_sync.pl" or die( $@ || $! );
ok $es->cluster->health, "$ENV{ES_CXN} - Non-cert HTTPS with auth, cxn sniff";

$ENV{ES_CXN_POOL} = 'Static::NoPing';
$es = do "es_sync.pl" or die( $@ || $! );
ok $es->cluster->health,
    "$ENV{ES_CXN} - Non-cert HTTPS with auth, cxn noping";

# Test forbidden action
throws_ok { $es->nodes->shutdown }
"Search::Elasticsearch::Error::Forbidden",
    "$ENV{ES_CXN} - Forbidden action";

# Test https connection with correct auth, with valid cacert
$Auth{ssl_options} = ssl_options( $ENV{ES_CA_PATH} );

$es = do "es_sync.pl" or die( $@ || $! );

ok $es->cluster->health, "$ENV{ES_CXN} - Valid cert HTTPS with auth";

# Test invalid user credentials
%Auth = ( userinfo => 'foobar:baz' );
$es = do "es_sync.pl" or die( $@ || $! );
throws_ok { $es->cluster->health }
"Search::Elasticsearch::Error::Unauthorized",
    "$ENV{ES_CXN} - Bad userinfo";

# Test https connection with correct auth, with invalid cacert
$Auth{ssl_options} = ssl_options('t/lib/bad_cacert.pem');
$ENV{ES}           = "https://www.google.com";

$es = do "es_sync.pl" or die( $@ || $! );

throws_ok { $es->cluster->health }
"Search::Elasticsearch::Error::$Throws_SSL",
    "$ENV{ES_CXN} - Invalid cert throws $Throws_SSL";

done_testing;

