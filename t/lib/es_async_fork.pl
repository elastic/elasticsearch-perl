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

