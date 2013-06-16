package Elasticsearch::NodePool;

use strict;
use warnings;
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params init_instance);
use Elasticsearch::Error qw(throw);
use List::Util qw(shuffle);
use IO::Select();
use Time::HiRes qw(time sleep);

my @Required_Params = qw(logger connection serializer);

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %defaults = $class->default_args;
    my $self     = bless {
        ping_timeout      => 1.0,
        ping_interval     => 300,
        ping_on_first_use => 1,
        %defaults,
    }, $class;

    init_instance( $self, \@Required_Params, $params );
    $self->{next_ping} = 0;
    $self->{nodes}     = [];
    $self->set_initial_nodes( $params->{nodes} );
    return $self;
}

#===================================
sub next_node    { throw( "Internal", "Must be overridden in subclass" ) }
sub mark_dead    { throw( "Internal", "Must be overridden in subclass" ) }
sub ping_fail    { throw( "Internal", "Must be overridden in subclass" ) }
sub ping_success { throw( "Internal", "Must be overridden in subclass" ) }
#===================================

#===================================
sub next_node_num {
#===================================
    my $self    = shift;
    my $nodes   = $self->nodes;
    my $current = $self->{current_node_num};
    $self->{current_node_num}
        = @$nodes
        ? ++$current % @$nodes
        : 0;
}

#===================================
sub set_initial_nodes {
#===================================
    my $self = shift;
    my @nodes = grep {$_} ref $_[0] ? @{ shift() } : @_;
    @nodes = 'localhost' unless @nodes;

    my $port = $self->connection->default_port;
    for (@nodes) {
        s{.+://}{};
        s{/.*$}{};
        $_ .= ":$port" unless m{:\d+$};
    }
    $self->set_nodes(@nodes);
}

#===================================
sub set_nodes {
#===================================
    my $self = shift;
    @{ $self->{nodes} } = shuffle @_;
    $self->{current_node_num} = 0;
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
    my $request    = $cxn->ping_request;
    my $response   = $cxn->ping_response;
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
            $write->remove($socket);
            if ( $socket->connected ) {
                $read->add($socket);
                $socket->send($request);
            }
        }

        for my $socket ( $read->can_read(0) ) {
            my $data;
            $socket->read( $data, length($response) );
            my $node = $sockets{"$socket"};
            if ( $data eq $response ) {
                $logger->debug("Successful response from node ($node)");

                if ( $self->ping_success($node) ) {
                    $logger->debug("Ending ping");
                    return $node;
                }
            }
            else {
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
sub next_ping {
#===================================
    my $self = shift;
    if (@_) {
        my $time = $self->{next_ping} = time() + shift();
        $self->logger->debug( "Next ping time: " . localtime($time) );
    }
    return $self->{next_ping};
}

#===================================
sub nodes             { $_[0]->{nodes} }
sub connection        { $_[0]->{connection} }
sub logger            { $_[0]->{logger} }
sub current_node_num  { $_[0]->{current_node_num} }
sub ping_timeout      { $_[0]->{ping_timeout} }
sub ping_interval     { $_[0]->{ping_interval} }
sub ping_on_first_use { $_[0]->{ping_on_first_use} }
sub serializer        { $_[0]->{serializer} }
sub default_args      { }
#===================================

1;
