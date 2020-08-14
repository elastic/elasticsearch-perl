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

use strict;
use warnings;

use Test::More;

use File::Temp;
use POSIX ":sys_wait_h";

use Search::Elasticsearch;
use Search::Elasticsearch::TestServer;

my @pids;

SKIP: {
    skip 'ES_HOME not set', 7 unless $ENV{ES_HOME};

    my $tempdir = File::Temp->newdir( 'testserver-XXXXX', DIR => '/tmp' );
    my $server = Search::Elasticsearch::TestServer->new;

    my $nodes = $server->start();

    ok( $nodes, "server->start returned nodes" )
        or diag explain { server => $server };
    ok( defined( $server->pids ), "server->pids defined" );
    cmp_ok( scalar @{ $server->pids }, '>', 0, "more than 0 pids" );
    @pids = @{ $server->pids };

    subtest 'ES pids are alive' => sub {
        verify_pids_alive(@pids);
    };

    $server->shutdown;

    note 'sleep to give ES time to die';
    sleep 5;

    subtest 'ES pids are dead after shutdown' => sub {
        verify_pids_dead(@pids);
    };

    eval { $server->shutdown };
    is( $@, '', "second shutdown did not set error" );

    subtest 'ES pids are dead after second shutdown' => sub {
        verify_pids_dead(@pids);
    };
}

done_testing;

#important to waitpid or kill0 will return true for zombies.
sub verify_pids_alive {
    for my $pid (@_) {
        waitpid( $pid, WNOHANG );
        ok( kill( 0, $pid ), "pid $pid is alive" );
    }
}

sub verify_pids_dead {
    for my $pid (@_) {
        waitpid( $pid, WNOHANG );
        ok( !kill( 0, $pid ), "pid $pid is dead" );
    }
}
