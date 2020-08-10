# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use POSIX ":sys_wait_h";
use AE;
use Promises qw(deferred);

my $es        = do "es_async.pl" or die( $@ || $! );
my $cxn_class = ref $es->transport->cxn_pool->cxns->[0];
ok wait_for( $es->info ), "$cxn_class - Info before fork";

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
        wait_for( $es->info );
    }
    exit;
}

my $ok = 0;
for ( 1 .. 10 ) {
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

