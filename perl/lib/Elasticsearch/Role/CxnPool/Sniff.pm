package Elasticsearch::Role::CxnPool::Sniff;

use Moo::Role;
with 'Elasticsearch::Role::CxnPool';
requires 'next_cxn', 'sniff', 'sniff_cxn';
use namespace::clean;

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
sub schedule_check {
#===================================
    my $self = shift;
    $self->logger->info("Require sniff before next request");
    $self->next_sniff(-1);
}

#===================================
sub parse_sniff {
#===================================
    my $self     = shift;
    my $protocol = shift;
    my $nodes    = shift or return;

    my @live_nodes;
    my $max       = 0;
    my $sniff_max = $self->sniff_max_content_length;

    for my $node_id ( keys %$nodes ) {
        my $data = $nodes->{$node_id};

        my $host = $data->{ $protocol . "_address" } or next;
        $host =~ s{^inet\[[^/]*/([^\]]+)\]}{$1} or next;

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

# ABSTRACT: A CxnPool role for connecting to a local cluster with a dynamic node list

