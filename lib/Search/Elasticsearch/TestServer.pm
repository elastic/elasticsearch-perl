package Search::Elasticsearch::TestServer;

use Moo;
use Search::Elasticsearch();
use POSIX 'setsid';
use File::Temp();
use IO::Socket();
use HTTP::Tiny;

use Search::Elasticsearch::Util qw(parse_params throw);
use namespace::clean;

has 'es_home'   => ( is => 'ro', required => 1 );
has 'instances' => ( is => 'ro', default  => 1 );
has 'http_port' => ( is => 'ro', default  => 9600 );
has 'es_port'   => ( is => 'ro', default  => 9700 );
has 'pids'      => ( is => 'ro', default  => sub { [] }, clearer => 1 );
has 'dir'       => ( is => 'ro', clearer  => 1 );
has 'conf' => ( is => 'ro', default => sub { [] } );

#===================================
sub start {
#===================================
    my $self = shift;

    my $home = $self->es_home
        or throw( 'Param', "Missing required param <es_home>" );
    my $instances = $self->instances;
    my $port      = $self->http_port;
    my $es_port   = $self->es_port;
    my @http      = map { $port++ } ( 1 .. $instances );
    my @transport = map { $es_port++ } ( 1 .. $instances );

    $self->_check_ports( @http, @transport );

    my $old_SIGINT = $SIG{INT};
    $SIG{INT} = sub {
        $self->shutdown;
        if ( ref $old_SIGINT eq 'CODE' ) {
            return $old_SIGINT->();
        }
        exit(1);
    };

    my $dir = File::Temp->newdir();
    for ( 0 .. $instances - 1 ) {
        print "Starting node: http://127.0.0.1:$http[$_]\n";
        $self->_start_node( $dir, $transport[$_], $http[$_] );
    }

    $self->_check_nodes(@http);
    return [ map {"http://127.0.0.1:$_"} @http ];
}

#===================================
sub _check_ports {
#===================================
    my $self = shift;
    for my $port (@_) {
        next unless IO::Socket::INET->new("127.0.0.1:$port");
        throw( 'Param',
                  "There is already a service running on 127.0.0.1:$port. "
                . "Please shut it down before starting the test server" );
    }
}

#===================================
sub _check_nodes {
#===================================
    my $self = shift;
    my $http = HTTP::Tiny->new;
    for my $node (@_) {
        print "Checking node: http://127.0.0.1:$node\n";
        my $i = 20;
        while (1) {
            last
                if $http->head("http://127.0.0.1:$node/")->{status} == 200;
            throw( 'Cxn', "Couldn't connect to http://127.0.0.1:$node" )
                unless $i--;
            sleep 1;
        }

    }
}

#===================================
sub _start_node {
#===================================
    my ( $self, $dir, $transport, $http ) = @_;

    my $pid_file = File::Temp->new;
    my @config = $self->_command_line( $pid_file, $dir, $transport, $http );

    my $int_caught = 0;
    {
        local $SIG{INT} = sub { $int_caught++; };
        defined( my $pid = fork )
            or throw( 'Internal', "Couldn't fork a new process: $!" );
        if ( $pid == 0 ) {
            throw( 'Internal', "Can't start a new session: $!" )
                if setsid == -1;
            exec(@config) or die "Couldn't execute @config: $!";
        }
        else {
            for ( 1 .. 5 ) {
                last if -s $pid_file->filename();
                sleep 1;
            }
            open my $pid_fh, '<', $pid_file->filename;
            my $pid = <$pid_fh>;
            throw( 'Internal', "No PID file found for Elasticsearch" )
                unless $pid;
            chomp $pid;
            push @{ $self->{pids} }, $pid;
        }
    }
    $SIG{INT}->('INT') if $int_caught;
}

#===================================
sub shutdown {
#===================================
    my $self = shift;
    local $?;

    my $pids = $self->pids;
    $self->clear_pids;
    return unless @$pids;

    kill 9, @$pids;
    $self->clear_dir;
}

#===================================
sub _command_line {
#===================================
    my ( $self, $pid_file, $dir, $transport, $http ) = @_;

    return (
        $self->es_home . '/bin/elasticsearch',
        '-p',
        $pid_file->filename,
        map {"-Des.$_"} (
            'path.data=' . $dir,
            'network.host=127.0.0.1',
            'cluster.name=es_test',
            'discovery.zen.ping.multicast.enabled=false',
            'discovery.zen.ping_timeout=1s',
            'discovery.zen.ping.unicast.hosts=127.0.0.1:' . $self->es_port,
            'transport.tcp.port=' . $transport,
            'http.port=' . $http,
            @{ $self->conf }
        )
    );
}

#===================================
sub DEMOLISH { shift->shutdown }
#===================================

1;

# ABSTRACT: A helper class to launch Elasticsearch nodes

=head1 DESCRIPTION

The L<Search::Elasticsearch::TestServer> class can be used to launch one or more
instances of Elasticsearch for testing purposes.  The nodes will
be shutdown automatically.

=head1 SYNOPSIS

    use Search::Elasticsearch;
    use Search::Elasticsearch::TestServer;

    my $server = Search::Elasticsearch::TestServer->new(
        es_home   => '/path/to/elasticsearch',
    );

    my $nodes = $server->start;
    my $es    = Search::Elasticsearch->new( nodes => $nodes );
    # run tests
    $server->shutdown;

=head1 METHODS

=head2 C<new()>

    my $server = Search::Elasticsearch::TestServer->new(
        es_home   => '/path/to/elasticsearch',
        instances => 1,
        http_port => 9600,
        es_port   => 9700,
        conf      => ['node.bench=true','script.disable_dynamic=false'],
    );

Params:

=over

=item * C<es_home>

Required. Must point to the Elasticsearch home directory, which contains
C<./bin/elasticsearch>.

=item * C<instances>

The number of nodes to start. Defaults to 1

=item * C<http_port>

The port to use for HTTP. If multiple instances are started, the C<http_port>
will be incremented for each subsequent instance. Defaults to 9600.

=item * C<es_port>

The port to use for Elasticsearch's internal transport. If multiple instances
are started, the C<es_port> will be incremented for each subsequent instance.
Defaults to 9700

=item * C<conf>

An array containing any extra startup options that should be passed
to Elasticsearch.

=back

=head1 C<start()>

    $nodes = $server->start;

Starts the required instances and returns an array ref containing the IP
and port of each node, suitable for passing to L<Search::Elasticsearch/new()>:

    $es = Search::Elasticsearch->new( nodes => $nodes );

=head1 C<shutdown()>

    $server->shutdown;

Kills the running instances.  This will be called automatically when
C<$server> goes out of scope or if the program receives a C<SIGINT>.


