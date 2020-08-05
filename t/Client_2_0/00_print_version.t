# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use lib 't/lib';
$ENV{ES_VERSION} = '2_0';
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

