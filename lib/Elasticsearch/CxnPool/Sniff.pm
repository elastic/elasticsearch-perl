package Elasticsearch::CxnPool::Sniff;

use Moo;
with 'Elasticsearch::Role::CxnPool';
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params);
use List::Util qw(min);
use Try::Tiny;

has 'sniff_interval' => ( is => 'ro', default => 300 );
has 'next_sniff'     => ( is => 'rw', default => 0 );
has 'sniff_max_content_length' => ( is => 'ro' );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    $params->{sniff_max_content_length} = !$params->{max_content_length}
        unless defined $params->{sniff_max_content_length};
    return $params;
}

#===================================
sub next_cxn {
#===================================
    my ($self) = @_;

    $self->sniff if $self->next_sniff <= time();

    my $cxns  = $self->cxns;
    my $total = @$cxns;

    while ( 0 < $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        return $cxn if $cxn->is_live;
    }

    throw( "NoNodes",
        "No nodes are available: [" . $self->cxns_seeds_str . ']' );
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
    my $self = shift;

    my $cxns  = $self->cxns;
    my $total = @$cxns;
    my @skipped;

    while ( 0 < $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        if ( $cxn->is_dead ) {
            push @skipped, $cxn;
        }
        else {
            $self->sniff_cxn($cxn) and return;
            $cxn->mark_dead;
        }
    }

    for my $cxn (@skipped) {
        $self->sniff_cxn($cxn) and return;
    }

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
    my @live_nodes;
    my $max       = 0;
    my $sniff_max = $self->sniff_max_content_length;

    for my $node_id ( keys %$nodes ) {
        my $data = $nodes->{$node_id};

        my $host = $data->{ $protocol . "_address" } or next;
        $host =~ s{^inet\[/([^\]]+)\]}{$1} or next;

        $host = $self->should_accept_node( $host, $node_id, $data )
            or next;

        push @live_nodes, $host;
        next unless $sniff_max and $data->{$protocol};

        my $node_max = $data->{$protocol}{max_content_length_in_bytes} || 0;
        $max
            = $node_max == 0 ? $max
            : $max == 0      ? $node_max
            :                  min( $node_max, $max );
    }

    return unless @live_nodes;

    $self->cxn_factory->max_content_length($max)
        if $sniff_max and $max;

    $self->set_cxns(@live_nodes);
    my $next = $self->next_sniff( time() + $self->sniff_interval );
    $self->logger->infof( "Next sniff at: %s", scalar localtime($next) );

    return 1;
}

#===================================
sub should_accept_node { return $_[1] }
#===================================

1;
