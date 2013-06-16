package Elasticsearch::NodePool::Static;

use strict;
use warnings;
use parent 'Elasticsearch::NodePool';
use namespace::autoclean;

use Elasticsearch::Error qw(throw);
use List::Util qw(min);
use Try::Tiny;

#===================================
sub new {
#===================================
    my $self = shift()->SUPER::new(@_);

    if ( $self->ping_on_first_use ) {
        $self->logger->debug("Force sniff on first request");
        $self->ping_fail( @{ $self->nodes } );
    }

    return $self;
}

#===================================
sub default_args {
#===================================
    return (
        ping_on_first_use => 0,
        ping_timeout      => 1.0,
        ping_interval     => 30,
        ping_on_failure   => 1,
        dead_timeout      => 60,
        max_dead_timeout  => 3600,
    );
}

#===================================
sub next_node {
#===================================
    my ( $self, $check_all ) = @_;

    my $nodes  = $self->nodes;
    my $dead   = $self->dead_nodes;
    my $now    = time();
    my $total  = @$nodes;
    my $logger = $self->logger;

    my @check;
    if ( $check_all or keys(%$dead) == $total ) {
        $logger->debug("Forced ping - no live nodes");
        @check = @$nodes;
        $self->next_ping( $self->ping_interval );
    }
    elsif ( $self->next_ping < $now ) {
        $logger->debug("Scheduled ping - checking for dead nodes");
        @check = grep { $dead->{$_} and $dead->{$_}[1] < $now } @$nodes;
        $self->next_ping( $self->ping_interval );
    }

    if (@check) {
        $self->ping_nodes(@check);
        $check_all++ if @check == $total;
    }

    while ( $total-- > 0 ) {
        my $next = $self->next_node_num;
        my $node = $nodes->[$next];
        if ( $dead->{$node} ) {
            $logger->debug( "Skipping dead node ($node) until "
                    . localtime( $dead->{$node}[1] ) );
            next;
        }
        return $node;
    }

    my $node = $self->next_node(1)
        unless $check_all;

    return $node || $logger->throw_critical(
        "NoNodes",
        "No nodes are available: ",
        { nodes => $self->nodes }
    );
}

#===================================
sub set_nodes {
#===================================
    my $self = shift;
    $self->SUPER::set_nodes(@_);
    %{ $self->{dead_nodes} } = ();
    return;
}

#===================================
sub mark_dead {
#===================================
    my ( $self, $node ) = @_;
    $self->logger->debug("Marking node ($node) as dead");
    $self->ping_fail($node);
    if ( $self->ping_on_failure ) {
        $self->logger->debug("Forced ping - failed node");
        $self->ping_nodes( @{ $self->nodes } );
    }
}

#===================================
sub ping_fail {
#===================================
    my $self   = shift;
    my $logger = $self->logger;
    for my $node (@_) {
        my $wait = $self->{dead_nodes}{$node} ||= [ 0, 0 ];

        my $timeout = min( $self->max_dead_timeout,
            $self->dead_timeout * 2**$wait->[0]++ );
        my $time = $wait->[1] = time + $timeout;
        $logger->debug(
            "Node ($node) marked dead until: " . localtime $time );
    }
}

#===================================
sub ping_success {
#===================================
    my ( $self, $node ) = @_;
    delete $self->dead_nodes->{$node};
    return;
}

#===================================
sub dead_timeout      { $_[0]->{dead_timeout} }
sub max_dead_timeout  { $_[0]->{max_dead_timeout} }
sub dead_nodes        { $_[0]->{dead_nodes} }
sub ping_on_failure   { $_[0]->{ping_on_failure} }
sub ping_on_first_use { $_[0]->{ping_on_first_use} }
#===================================

1;
