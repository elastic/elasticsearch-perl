package Elasticsearch::NodePool::Sniff;

use strict;
use warnings;
use parent 'Elasticsearch::NodePool';
use namespace::autoclean;

use Elasticsearch::Error qw(throw);
use Try::Tiny;

# add max content?

#===================================
sub new {
#===================================
    my $self = shift()->SUPER::new(@_);
    $self->{original_nodes} = [ @{ $self->nodes } ];

    $self->set_nodes()
        if $self->ping_on_first_use;

    return $self;
}

#===================================
sub default_args {
#===================================
    return (
        ping_interval_after_failure => 120,
        ping_on_first_use           => 1,
        should_accept_node          => sub {1}
    );
}

#===================================
sub next_node {
#===================================
    my $self = shift;

    my $nodes = $self->nodes;
    my $now   = time();

    if ( @$nodes and $self->next_ping < $now ) {
        $self->ping_nodes(@$nodes);
        $self->next_ping( $self->ping_interval );
    }

    if ( @$nodes == 0 ) {
        $self->ping_nodes( @$nodes, @{ $self->original_nodes } );

        if ( @$nodes == 0 ) {
            throw(
                "NoNodes",
                "No nodes are available: ",
                { nodes => $self->original_nodes }
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
    $self->set_nodes( grep { $_ ne $node } @{ $self->nodes } );
    $self->next_ping( $self->ping_interval_after_failure );
}

#===================================
sub ping_fail { }
#===================================

#===================================
sub ping_success {
#===================================
    my ( $self, $node ) = @_;
    my $cxn   = $self->connection;
    my $nodes = try {
        my $raw = $cxn->perform_request(
            $node,
            {   method => 'GET',
                path   => '/_cluster/nodes',
                qs     => { timeout => 300 }
            }
        );
        return $self->serializer->decode($raw)->{nodes};
    }
    catch {
        warn "$_";
        0;
    } or return;

    my $protocol_key = $cxn->protocol . '_address';

    my @live_nodes;
    for my $node_id ( keys %$nodes ) {
        my $data = $nodes->{$node_id};
        my $host = $data->{$protocol_key} or next;
        $host =~ s{^inet\[/([^\]]+)\]}{$1} or next;
        $self->should_accept_node( $host, $node_id, $data ) or next;
        push @live_nodes, $host;
    }

    return unless @live_nodes;

    $self->set_nodes(@live_nodes);
    return 1;
}

#===================================
sub ping_interval_after_failure { $_[0]->{ping_interval_after_failure} }
sub original_nodes              { $_[0]->{original_nodes} }
sub should_accept_node          { shift()->{should_accept_node}->(@_) }
#===================================
1;
