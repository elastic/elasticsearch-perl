package Elasticsearch::Role::CxnPool::Static;

use Moo::Role;
with 'Elasticsearch::Role::CxnPool';
requires 'next_cxn';

use namespace::clean;

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->set_cxns( @{ $self->seed_nodes } );
    $self->schedule_check;
}

#===================================
sub schedule_check {
#===================================
    my ($self) = @_;
    $self->logger->info("Forcing ping before next use on all live cxns");
    for my $cxn ( @{ $self->cxns } ) {
        next if $cxn->is_dead;
        $self->logger->infof( "Ping [%s] before next request",
            $cxn->stringify );
        $cxn->force_ping;
    }
}

1;

__END__

# ABSTRACT: A CxnPool for connecting to a remote cluster with a static list of nodes.

=head1 SYNOPSIS


    $e = Elasticsearch->new(
        cxn_pool => 'Static'     # default
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

=head1 DESCRIPTION

The L<Static|Elasticsearch::CxnPool::Static> connection pool, which is the
default, should be used when you don't have direct access to the Elasticsearch
cluster, eg when you are accessing the cluster through a proxy.  It
round-robins through the nodes that you specified, and pings each node
before it is used for  the first time, to ensure that it is responding.

If any node fails, then all nodes are pinged before the next request to
ensure that they are still alive and responding.  Failed nodes will be
pinged regularly to check if they have recovered.

This class does L<Elasticsearch::Role::CxnPool>.

=head1 CONFIGURATION

=head2 C<nodes>

The list of nodes to use to serve requests.  Can accept a single node,
multiple nodes, and defaults to C<localhost:9200> if no C<nodes> are
specified. See L<Elasticsearch::Role::Cxn::HTTP/node> for details of the node
specification.

=head2 See also

=over

=item *

L<Elasticsearch::Role::Cxn/request_timeout>

=item *

L<Elasticsearch::Role::Cxn/ping_timeout>

=item *

L<Elasticsearch::Role::Cxn/dead_timeout>

=item *

L<Elasticsearch::Role::Cxn/max_dead_timeout>

=back

=head1 METHODS

=head2 C<next_cxn()>

    $cxn = $cxn_pool->next_cxn

Returns the next available live node (in round robin fashion), or
throws a C<NoNodes> error if no nodes respond to ping requests.

=head2 C<schedule_check()>

    $cxn_pool->schedule_check

Forces a ping on all live nodes before their next use, to check that they
are still alive.
