use Test::More;
use Test::SharedFork;
use Search::Elasticsearch;
use POSIX ":sys_wait_h";

my $es        = do "es_sync.pl";
my $cxn_class = ref $es->transport->cxn_pool->cxns->[0];
ok $es->info, "$cxn_class - Info before fork";

my $Kids = 4;
my %pids;

for my $child ( 1 .. $Kids ) {
    my $pid = fork();
    if ($pid) {
        $pids{$pid} = $child;
        next;
    }
    if ( !defined $pid ) {
        skip "fork() not supported";
        done_testing;
        last;
    }

    for ( 1 .. 100 ) {
        $es->info;
    }
    exit;
}

my $ok = 0;
for ( 1 .. 5 ) {
    my $pid = waitpid( -1, WNOHANG );
    if ( $pid > 0 ) {
        delete $pids{$pid};
        $ok++ unless $?;
        redo;
    }
    last unless keys %pids;
    sleep 1;
}

is $ok, $Kids, "$cxn_class - Fork";
done_testing;
