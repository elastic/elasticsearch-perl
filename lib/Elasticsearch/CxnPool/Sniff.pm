package Elasticsearch::CxnPool::Sniff;

use Moo;
with 'Elasticsearch::Role::CxnPool';
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params);
use List::Util qw(min);
use Try::Tiny;

has 'sniff_interval'           => ( is => 'ro', default => 300 );
has 'next_sniff'               => ( is => 'rw', default => 0 );
has 'sniff_max_content_length' => ( is => 'ro', default => 1 );

#===================================
sub next_cxn {
#===================================
    my ( $self, $force ) = @_;

    $self->sniff($force);

    my $cxns  = $self->cxns;
    my $total = @$cxns;

    while ( 0 < $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        return $cxn if $cxn->is_live;
    }

    throw( "NoNodes",
        "No nodes are available: [" . $self->cxns_seeds_str . ']' )
        if $force;

    return $self->next_cxn(1);
}

#===================================
sub schedule_check {
#===================================
    my $self = shift;
    $self->logger->info("Require sniff before next request");
    $self->next_sniff(-1);
}

#===================================
sub sniff {
#===================================
    my ( $self, $force ) = @_;

    return unless $force || $self->next_sniff <= time();

    my $cxns  = $self->cxns;
    my $total = @$cxns;

    while ( 0 < $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        next if $cxn->is_dead xor $force;
        $self->sniff_cxn($cxn) and return;
    }

    return if $force;

    $self->logger->infof("No live nodes available. Trying seed nodes.");
    for my $seed ( @{ $self->seed_nodes } ) {
        my $cxn = $self->cxn_factory->new_cxn($seed);
        $self->sniff_cxn($cxn) and return;
    }

}

#===================================
sub sniff_cxn {
#===================================
    my $self = shift;
    my $cxn  = shift;

    my $nodes = $cxn->sniff or return;
    my $protocol = $cxn->protocol;

    my ( $max, @live_nodes );
    my $sniff_max = $self->sniff_max_content_length;

    for my $node_id ( keys %$nodes ) {
        my $data = $nodes->{$node_id};

        my $host = $data->{ $protocol . "_address" } or next;
        $host =~ s{^inet\[/([^\]]+)\]}{$1} or next;

        $self->should_accept_node( $host, $node_id, $data )
            or next;

        push @live_nodes, $host;
        next unless $sniff_max and $data->{protocol};

        my $node_max = $data->{$protocol}{max_content_length_in_bytes} || 0;
        $max
            = $node_max == 0 ? $max
            : $max == 0      ? $node_max
            :                  min( $node_max, $max );
    }

    return unless @live_nodes;

    $self->set_cxns(@live_nodes);
    my $next = $self->next_sniff( time() + $self->sniff_interval );
    $self->logger->infof( "Next sniff at: %s", scalar localtime($next) );

    $self->max_content_length($max)
        if $sniff_max and $max;

    return 1;
}

#===================================
sub should_accept_node {
#===================================
    return 1;
}

1;
