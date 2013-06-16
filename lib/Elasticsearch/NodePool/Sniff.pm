package Elasticsearch::NodePool::Sniff;

use Moo;
with 'Elasticsearch::Role::NodePool';
use namespace::autoclean;

use Try::Tiny;

has 'ping_interval_after_failure' => ( is => 'ro', default => 120 );
has 'should_accept_node' => (
    is      => 'ro',
    default => sub {
        sub {1}
    }
);

# add max content?

#===================================
after 'BUILD' => sub {
#===================================
    my $self = shift;
    if ( $self->ping_on_first_use ) {
        $self->logger->debug("Force sniff on first request");
        $self->set_nodes();
    }
};

#===================================
sub next_node {
#===================================
    my $self = shift;

    my $nodes  = $self->nodes;
    my $now    = time();
    my $logger = $self->logger;
    my $debug  = $logger->is_debug;

    if ( @$nodes and $self->next_ping < $now ) {
        $logger->debug("Starting scheduled ping");
        $self->ping_nodes(@$nodes);
        $self->next_ping( $self->ping_interval );
    }

    if ( @$nodes == 0 ) {
        $logger->debug("Forced ping - no live nodes");
        $self->ping_nodes( @$nodes, @{ $self->seed_nodes } );

        if ( @$nodes == 0 ) {
            throw(
                "NoNodes",
                "No nodes are available: ",
                { nodes => $self->seed_nodes }
            );
        }
        $self->next_ping( $self->ping_interval );
    }
    return $nodes->[ $self->next_node_num ];
}

#===================================
sub mark_dead {
#===================================
    my ( $self, $node ) = @_;
    $self->logger->debug("Marking node ($node) as dead");
    $self->set_nodes( grep { $_ ne $node } @{ $self->nodes } );
    $self->next_ping( $self->ping_interval_after_failure );
}

#===================================
sub ping_fail {
#===================================
    my ( $self, @nodes ) = @_;
    $self->logger->debugf( "Ping failed for nodes: %s", \@nodes );
}

#===================================
sub ping_success {
#===================================
    my ( $self, $node ) = @_;
    my $logger = $self->logger;
    $logger->debug("Retrieving live node list from node ($node)");

    my $cxn   = $self->connection;
    my $nodes = try {
        my $raw = $cxn->perform_request(
            $node,
            {   method => 'GET',
                path   => '/_cluster/nodes',
                qs     => { timeout => 300 },
                prefix => '',
            }
        );
        return $self->serializer->decode($raw)->{nodes};
    }
    catch {
        $logger->warn("$_");
        0;
    } or return;

    my $protocol_key = $cxn->protocol . '_address';

    my @live_nodes;
    for my $node_id ( keys %$nodes ) {
        my $data = $nodes->{$node_id};
        my $host = $data->{$protocol_key} or next;
        $host =~ s{^inet\[/([^\]]+)\]}{$1} or next;
        $self->should_accept_node->( $host, $node_id, $data ) or next;
        push @live_nodes, $host;
    }

    unless (@live_nodes) {
        $logger->warn("No live nodes returned from node ($node)");
        return;
    }

    $self->set_nodes(@live_nodes);
    return 1;
}

1;
