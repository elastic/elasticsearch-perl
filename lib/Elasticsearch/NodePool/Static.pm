package Elasticsearch::NodePool::Static;

use strict;
use warnings;
use parent 'Elasticsearch::NodePool';
use namespace::autoclean;

use Elasticsearch::Error qw(throw);
use Try::Tiny;

#===================================
sub new {
#===================================
    my $self = shift()->SUPER::new(@_);

    $self->ping_fail( @{ $self->nodes } )
        if $self->ping_on_first_use;

    return $self;
}

#===================================
sub default_args {
#===================================
    return (
        ping_timeout     => 1.0,
        ping_interval    => 30,
        ping_on_failure  => 1,
        dead_timeout     => 60,
        max_dead_timeout => 3600,
    );
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
        $self->next_ping( $self->ping_interval );
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
    my $self = shift;
    $self->ping_fail(@_);
    $self->ping_nodes( @{ $self->nodes } )
        if $self->ping_on_failure;
}

#===================================
sub ping_fail {
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
sub dead_timeout      { $_[0]->{dead_timeout} }
sub max_dead_timeout  { $_[0]->{max_dead_timeout} }
sub dead_nodes        { $_[0]->{dead_nodes} }
sub ping_on_failure   { $_[0]->{ping_on_failure} }
sub ping_on_first_use { $_[0]->{ping_on_first_use} }
#===================================

1;
