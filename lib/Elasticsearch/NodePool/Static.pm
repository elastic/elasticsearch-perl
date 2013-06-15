package Elasticsearch::NodePool::Static;

use strict;
use warnings;
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params init_instance);
use Elasticsearch::Error qw(throw);
use URI();
use List::Util qw(shuffle min);
use Try::Tiny;
use IO::Socket;
use IO::Select;
use Time::HiRes qw(time sleep);

my @Required_Params = qw(logger connection);

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $self = bless {
        ping_timeout      => 1.0,
        ping_interval     => 30,
        dead_timeout      => 60,
        max_dead_timeout  => 3600,
        next_ping         => 0,
        ping_on_failure   => 1,
        ping_on_first_use => 1,
    }, $class;

    init_instance( $self, \@Required_Params, $params );

    $self->set_initial_nodes( $params->{nodes} );
    $self->mark_dead_no_ping( @{ $self->nodes } )
        if $self->ping_on_first_use;

    return $self;
}

#===================================
sub next_node {
#===================================
    my ( $self, $check_all ) = @_;

    my $nodes = $self->nodes;
    my $dead  = $self->dead_nodes;
    my $now   = time();
    my $total = @$nodes;

    my @check;
    if ($check_all) {
        @check = @$nodes;
    }
    elsif ( $self->next_ping < $now ) {
        @check = grep { $dead->{$_} and $dead->{$_}[1] < $now } @$nodes;
    }

    if (@check) {
        $self->ping_nodes(@check);
        $check_all++ if @check == $total;
    }

    while ( $total-- > 0 ) {
        my $next = $self->next_node_num;
        my $node = $nodes->[$next];
        next if $dead->{$node};
        return $node;
    }

    my $node = $self->next_node(1)
        unless $check_all;

    return $node || throw(
        "NoNodes",
        "No nodes are available: ",
        { nodes => $self->nodes }
    );
}

#===================================
sub next_node_num {
#===================================
    my $self = shift;
    $self->{current_node_num}
        = ++$self->{current_node_num} % @{ $self->{nodes} };
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
    $self->{nodes}            = [ shuffle @_ ];
    $self->{current_node_num} = 0;
    $self->{dead_nodes}       = {};
    return;
}

#===================================
sub mark_dead {
#===================================
    my $self = shift;
    $self->mark_dead_no_ping(@_);
    $self->ping_nodes( @{ $self->nodes } )
        if $self->ping_on_failure;
}

#===================================
sub mark_dead_no_ping {
#===================================
    my $self = shift;
    for my $node (@_) {
        my $wait = $self->{dead_nodes}{$node} ||= [ 0, 0 ];
        my $timeout = min( $self->dead_timeout * 2**$wait->[0]++,
            $self->max_dead_timeout );
        $wait->[1] = time + $timeout;
    }
}

#===================================
sub mark_alive {
#===================================
    my $self = shift;
    return unless @_;
    delete @{ $self->{dead_nodes} }{@_};
}

#===================================
sub ping_nodes {
#===================================
    my ( $self, @nodes ) = @_;

    # support https and auth
    my $request  = "GET / HTTP/1.1\015\012\015\012";
    my $response = "HTTP/1.1 200 OK";

    my $poll_delay = 0.01;
    my $end_time   = time() + $self->ping_timeout;
    my $write      = IO::Select->new;
    my $read       = IO::Select->new;

    my ( %sockets, @success );
    for my $node (@nodes) {
        my $socket = IO::Socket::INET->new(
            PeerAddr => $node,
            Proto    => 'tcp',
            Blocking => 0
        ) or next;
        $sockets{"$socket"} = $node;
        $write->add($socket);
    }

    while ( time < $end_time ) {
        for my $socket ( $write->can_write(0) ) {
            $socket->connected or next;
            $write->remove($socket);
            $read->add($socket);
            $socket->send($request);
        }

        for my $socket ( $read->can_read(0) ) {
            my $data;
            $socket->read( $data, length($response) );
            push @success, $sockets{"$socket"}
                if $data eq $response;
            $read->remove($socket);
            delete $sockets{$socket};
        }
        last unless $write->handles || $read->handles;
        sleep $poll_delay;
    }
    $self->mark_dead_no_ping( values %sockets );
    $self->mark_alive(@success);
    return 0 + @success;
}

#===================================
sub next_ping {
#===================================
    my $self = shift;
    $self->{next_ping} = shift() if @_;
    return $self->{next_ping};
}

#===================================
sub nodes             { $_[0]->{nodes} }
sub connection        { $_[0]->{connection} }
sub current_node_num  { $_[0]->{current_node_num} }
sub dead_timeout      { $_[0]->{dead_timeout} }
sub max_dead_timeout  { $_[0]->{max_dead_timeout} }
sub ping_timeout      { $_[0]->{ping_timeout} }
sub dead_nodes        { $_[0]->{dead_nodes} }
sub ping_on_failure   { $_[0]->{ping_on_failure} }
sub ping_on_first_use { $_[0]->{ping_on_first_use} }
#===================================

1;
