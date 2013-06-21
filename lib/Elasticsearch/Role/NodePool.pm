package Elasticsearch::Role::NodePool;

use Moo::Role;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use List::Util qw(shuffle);
use IO::Select();
use Time::HiRes qw(time sleep);

requires qw(next_node mark_dead ping_fail ping_success);

has 'logger'            => ( is => 'ro',  required => 1 );
has 'connection'        => ( is => 'ro',  required => 1 );
has 'serializer'        => ( is => 'ro',  required => 1 );
has 'ping_timeout'      => ( is => 'ro',  default  => 1.0 );
has 'ping_interval'     => ( is => 'ro',  default  => 300 );
has 'ping_on_first_use' => ( is => 'ro',  default  => 1 );
has 'current_node_num'  => ( is => 'rwp', default  => 0 );

has 'next_ping' => (
    is      => 'rw',
    default => 0,
    coerce  => sub { shift() + time() },
    trigger => 1
);

has 'seed_nodes' => (
    is       => 'ro',
    init_arg => 'nodes',
    default  => sub { [] },
    coerce   => sub { ref $_[0] eq 'ARRAY' ? $_[0] : [ $_[0] ] }
);

has 'nodes' => (
    is       => 'ro',
    default  => sub { [] },
    init_arg => undef
);

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->_init_nodes();
    return $self;
}

#===================================
sub next_node_num {
#===================================
    my $self    = shift;
    my $nodes   = $self->nodes;
    my $current = $self->current_node_num;
    $self->_set_current_node_num( @$nodes ? ++$current % @$nodes : 0 );
}

#===================================
sub _init_nodes {
#===================================
    my $self  = shift;
    my $seed  = $self->seed_nodes;
    my @nodes = grep {$_} @$seed;
    @nodes = 'localhost' unless @nodes;

    my $port = $self->connection->default_port;
    for (@nodes) {
        s{.+://}{};
        s{/.*$}{};
        $_ .= ":$port" unless m{:\d+$};
    }
    @$seed = @nodes;
    $self->set_nodes(@nodes);
}

#===================================
sub set_nodes {
#===================================
    my $self = shift;
    @{ $self->nodes } = shuffle @_;
    $self->_set_current_node_num(0);
    $self->logger->debugf( "Set live nodes: %s", $self->{nodes} );
    return;
}

#===================================
sub ping_nodes {
#===================================
    my ( $self, @nodes ) = @_;

    my $logger = $self->logger;
    $logger->debugf( "Pinging nodes: %s", \@nodes );

    my $poll_delay = 0.01;
    my $end_time   = time() + $self->ping_timeout;
    my $cxn        = $self->connection;
    my $write      = IO::Select->new;
    my $read       = IO::Select->new;

    my (%sockets);
    for my $node (@nodes) {
        local $!;
        my $socket = $cxn->open_socket($node);
        if ($socket) {
            $sockets{"$socket"} = $node;
            $write->add($socket);
        }
        else {
            $logger->warn("Couldn't open a socket to node ($node): $!");
            $self->ping_fail($node);
        }
    }

    while ( time < $end_time ) {
        for my $socket ( $write->can_write(0) ) {
            my $node = $sockets{"$socket"};
            $write->remove($socket);

            if ( $socket->connected ) {
                $logger->debug("Sending request to node ($node)");
                $read->add($socket);
                $socket->print( $cxn->ping_request($node) );
            }
            else {
                $logger->debug("Node ($node) not contactable");
            }
        }

        for my $socket ( $read->can_read(0) ) {
            my $data = '';
            $socket->read( $data, $cxn->ping_response_length );

            my $node = $sockets{"$socket"};
            if ( $cxn->valid_ping_response($data) ) {
                $logger->debug("Successful response from node ($node)");

                if ( $self->ping_success($node) ) {
                    $logger->debug("Ping completed successfully");
                    return $node;
                }
            }
            else {
                $data =~ s/[\r\n]/[NL]/g;
                $logger->debugf( "Node ($node) responded incorrectly: %s",
                    $data );
            }
            $read->remove($socket);
            delete $sockets{$socket};
        }
        last unless $write->handles || $read->handles;
        sleep $poll_delay;
    }
    $self->ping_fail( values %sockets );
    return;
}

#===================================
sub _trigger_next_ping {
#===================================
    my $self = shift;
    $self->logger->debug( "Next ping time: " . localtime $self->next_ping );
}

1;
