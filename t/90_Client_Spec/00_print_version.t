use Test::More;
use lib 't/lib';
my $es = do "es_test_server.pl";

eval {
    my $v = $es->info->{version};
    diag "";
    diag "";
    diag "Testing against Elasticsearch v" . $v->{number};
    for ( sort keys %$v ) {
        diag sprintf "%-20s: %s", $_, $v->{$_};
    }
    diag "";
    pass "ES Version";
} or fail "ES Version";

done_testing;

