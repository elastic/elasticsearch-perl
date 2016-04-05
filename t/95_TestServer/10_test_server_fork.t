use strict;
use warnings;

use Test::More;
use Test::SharedFork;

use File::Temp;
use POSIX ":sys_wait_h";

use Search::Elasticsearch;
use Search::Elasticsearch::TestServer;

my $pids = [];

SKIP: {
    skip 'ES_HOME not set', 8 unless $ENV{ES_HOME};

    my $tempdir = File::Temp->newdir( 'testserver-XXXXX', DIR => '/tmp' );
    my $server = Search::Elasticsearch::TestServer->new(
        es_home => $ENV{ES_HOME},
        conf    => [ "path.data=$tempdir", "path.logs=$tempdir", ]
    );

    my $nodes = $server->start();

    ok( $nodes, "server->start returned nodes" )
        or diag explain { server => $server };
    ok( defined( $server->pids ), "server->pids defined" );
    cmp_ok( scalar @{ $server->pids }, '>', 0, "more than 0 pids" );
    $pids = \@{ $server->pids };

    verify_pids_alive( $pids, 'ES pids are alive' );

    {
        my $pid = fork;
        die "cannot fork" unless defined $pid;

        if ( $pid == 0 ) {
            verify_pids_alive( $pids, 'ES pids are alive in child' );
            exit 0;
        }
        else {
            verify_pids_alive( $pids, 'ES pids are alive in parent' );
            waitpid( $pid, 0 );
            sleep 5;
            verify_pids_alive( $pids,
                'ES pids are alive in parent after child dies' );
        }
    }

    $server->shutdown;

    note 'sleep to give ES time to die';
    sleep 5;

    verify_pids_dead( $pids, 'ES pids are dead after shutdown' );

}
done_testing;

#important to waitpid or kill0 will return true for zombies.
sub verify_pids_alive {
    my ( $pids, $msg ) = @_;
    $msg = '' if !defined $msg;
    for my $pid (@$pids) {
        waitpid( $pid, WNOHANG );
        ok( kill( 0, $pid ), "$msg: pid $pid is alive" );
    }
}

sub verify_pids_dead {
    my ( $pids, $msg ) = @_;
    $msg = '' if !defined $msg;
    for my $pid (@$pids) {
        waitpid( $pid, WNOHANG );
        ok( !kill( 0, $pid ), "$msg: pid $pid is dead" );
    }
}
