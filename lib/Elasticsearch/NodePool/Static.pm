package Elasticsearch::NodePool::Static;

use Moo;
with 'Elasticsearch::Role::NodePool';
use namespace::autoclean;

use List::Util qw(min);
use Try::Tiny;

has '+ping_interval'   => ( default => 60 );
has 'ping_on_failure'  => ( is      => 'ro', default => 1 );
has 'dead_timeout'     => ( is      => 'ro', default => 60 );
has 'max_dead_timeout' => ( is      => 'ro', default => 3600 );
has 'dead_nodes' => (
    is       => 'ro',
    default  => sub { +{} },
    init_arg => undef
);

#===================================
after 'BUILD' => sub {
#===================================
    my $self = shift;
    if ( $self->ping_on_first_use ) {
        $self->logger->debug("Force sniff on first request");
        $self->ping_fail( @{ $self->nodes } );
    }
};

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
after 'set_nodes' => sub { %{ shift()->{dead_nodes} } = () };
#===================================

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
1;
