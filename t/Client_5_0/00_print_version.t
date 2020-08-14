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
use lib 't/lib';
$ENV{ES_VERSION} = '5_0';
my $es = do "es_sync.pl" or die( $@ || $! );

eval {
    my $v = $es->info->{version};
    diag "";
    diag "";
    diag "Testing against Elasticsearch v" . $v->{number};
    for ( sort keys %$v ) {
        diag sprintf "%-20s: %s", $_, $v->{$_};
    }
    diag "";
    diag "Client:   " . ref($es);
    diag "Cxn:      " . $es->transport->cxn_pool->cxn_factory->cxn_class;
    diag "GET Body: " . $es->transport->send_get_body_as;
    diag "";
    pass "ES Version";
} or fail "ES Version";

done_testing;

