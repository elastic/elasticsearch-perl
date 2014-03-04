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

__END__

# ABSTRACT: A CxnPool role for connecting to a local cluster with a dynamic node list

=head1 CONFIGURATION

=head2 C<sniff_interval>

How often should we perform a sniff in order to detect whether new nodes
have been added to the cluster.  Defaults to `300` seconds.

=head2 C<sniff_max_content_length>

Whether we should set the
L<max_content_length|Elasticsearch::Role::Cxn::HTTP/max_content_length>
dynamically while sniffing. Defaults to true unless a fixed
C<max_content_length> was specified.

=head1 METHODS

=head2 C<schedule_check()>

    $cxn_pool->schedule_check

Schedules a sniff before the next request is processed.

=head2 C<parse_sniff()>

    $bool = $cxn_pool->parse_sniff(\%nodes);

Parses the response from a sniff request and extracts the hostname/ip
of all listed nodes, filtered through L</should_accept_node()>. If any live
nodes are found, they are passed to L<Elasticsearch::Role::CxnPool/set_cxns()>.
The L<max_content_length|Elasticsearch::Role::Cxn::HTTP/max_content_length>
is also detected if L</sniff_max_content_length> is true.

=head2 C<should_accept_node()>

    $host = $cxn_pool->should_accept_node($host,$node_id,\%node_data)

This method serves as a hook which can be overridden by the user.  When
a sniff is performed, this method is called with the C<host>
(eg C<192.168.5.100:9200>), the C<node_id> (the ID assigned to the node
by Elasticsearch) and the C<node_data> which contains the information
about the node that Elasticsearch has returned, eg:

    {
        "transport_address" => "inet[192.168.5.100/192.168.5.100:9300]",
        "http" : {
           "publish_address"    => "inet[/192.168.5.100:9200]",
           "max_content_length" => "100mb",
           "bound_address"      => "inet[/0:0:0:0:0:0:0:0:9200]",
           "max_content_length_in_bytes" : 104857600
        },
        "version"       => "0.90.4",
        "name"          => "Silver Sable",
        "hostname"      => "search1.domain.com",
        "http_address"  => "inet[/192.168.5.100:9200]"
    }

If the node should be I<accepted> (ie used to serve data), then it should
return the C<host> value to use.  By default, nodes are always
accepted.

