package Elasticsearch::CxnPool::Sniff;

use Moo;
with 'Elasticsearch::Role::CxnPool::Sniff', 'Elasticsearch::Role::Is_Sync';

use Elasticsearch::Util qw(throw);
use namespace::clean;

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
    my ( $self, $cxn ) = @_;
    return $self->parse_sniff( $cxn->protocol, $cxn->sniff );
}

1;

# ABSTRACT: A CxnPool for connecting to a local cluster with a dynamic node list

=head1 SYNOPSIS


    $e = Elasticsearch->new(
        cxn_pool => 'Sniff',
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

=head1 DESCRIPTION

The L<Sniff|Elasticsearch::CxnPool::Sniff> connection pool should be used
when you B<do> have direct access to the Elasticsearch cluster, eg when
your web servers and Elasticsearch servers are on the same network.
The nodes that you specify are used to I<discover> the cluster, which is
then I<sniffed> to find the current list of live nodes that the cluster
knows about.

This sniff process is repeated regularly, or whenever a node fails,
to update the list of healthy nodes.  So if you add more nodes to your
cluster, they will be auto-discovered during a sniff.

If all sniffed nodes fail, then it falls back to sniffing the original
I<seed> nodes that you specified in C<new()>.

For L<HTTP Cxn classes|Elasticsearch::Role::Cxn::HTTP>, this module
will also dynamically detect the C<max_content_length> which the nodes
in the cluster will accept.

This class does L<Elasticsearch::Role::CxnPool::Sniff> and
L<Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 C<nodes>

The list of nodes to use to discover the cluster.  Can accept a single node,
multiple nodes, and defaults to C<localhost:9200> if no C<nodes> are
specified. See L<Elasticsearch::Role::Cxn::HTTP/node> for details of the node
specification.

=head2 C<sniff_interval>

    $e = Elasticsearch->new(
        cxn_pool       => 'Sniff',
        nodes          => [...],
        sniff_interval => 300,
    );

How often to perform a sniff to detect new nodes in the cluster.  Defaults to
C<300> seconds.  B<Note:> In case of node failure, the cluster will be
resniffed before the next request to update the list of healthy nodes.

=head2 C<sniff_max_content_length>

    $e = Elasticsearch->new(
        cxn_pool                 => 'Sniff',
        nodes                    => [...],
        sniff_max_content_length => 0,
    );

Whether C<max_content_length> should be dynamically updated based on the
value returned from each node in the cluster.  This defaults to C<true>
unless you have manually set L<Elasticsearch::Cxn::HTTP/max_content_length>.

=head2 See also

=over

=item *

L<Elasticsearch::Role::Cxn/request_timeout>

=item *

L<Elasticsearch::Role::Cxn/sniff_timeout>

=item *

L<Elasticsearch::Role::Cxn/sniff_request_timeout>

=back

=head1 METHODS

=head2 C<next_cxn()>

    $cxn = $cxn_pool->next_cxn

Returns the next available live node (in round robin fashion), or
throws a C<NoNodes> error if no nodes can be sniffed from the cluster.

=head2 C<schedule_check()>

    $cxn_pool->schedule_check

Forces a sniff before the next Cxn is returned, to updated the list of healthy
nodes in the cluster.

=head2 C<sniff()>

    $bool = $cxn_pool->sniff

Sniffs the cluster and returns C<true> if the sniff was successful.

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
return the C<host> value which to use.  By default, nodes are always
accepted.

