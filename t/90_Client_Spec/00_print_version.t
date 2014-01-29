use Test::More;
use lib 't/lib';
my $es = do "es_sync.pl";

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

