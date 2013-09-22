package Elasticsearch::CxnPool::Static::NoPing;

use Moo;
with 'Elasticsearch::Role::CxnPool';
use namespace::autoclean;

has 'max_retries' => ( is => 'lazy' );
has '_dead_cxns' => ( is => 'ro', default => sub { [] } );

#===================================
sub _build_max_retries { @{ shift->cxns } - 1 }
sub _max_retries       { shift->max_retries + 1 }
#===================================

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->set_cxns( @{ $self->seed_nodes } );
}

#===================================
sub next_cxn {
#===================================
    my $self = shift;

    my $cxns  = $self->cxns;
    my $total = @$cxns;
    my $dead  = $self->_dead_cxns;

    while ( $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        return $cxn
            if $cxn->is_live
            || $cxn->next_ping < time();
        push @$dead, $cxn unless grep { $_ eq $cxn } @$dead;
    }

    if ( @$dead and $self->retries <= $self->max_retries ) {
        $_->force_ping for @$dead;
        return shift @$dead;
    }
    throw( "NoNodes", "No nodes are available: [" . $self->cxns_str . ']' );
}

#===================================
sub should_mark_dead {
#===================================
    my ( $self, $error ) = @_;
    return $error->is( 'Cxn', 'Timeout' );
}

#===================================
after 'reset_retries' => sub {
#===================================
    my $self = shift;
    @{ $self->_dead_cxns } = ();

};

#===================================
sub schedule_check { }
#===================================

1;

__END__

# ABSTRACT: A CxnPool for connecting to a remote cluster without the ability to ping.

=head1 SYNOPSIS

    $e = Elasticsearch->new(
        cxn_pool => 'Static::NoPing'
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

=head1 DESCRIPTION

The L<Static::NoPing|Elasticsearch::CxnPool::Static::NoPing> connection
pool (like the L<Static|ElasticSearch::CxnPool::Static> pool) should be used
when your access to the cluster is limited.  However, the C<Static> pool needs
to be able to ping nodes in the cluster, with a C<HEAD /> request.  If you
can't ping your nodes, then you should use the C<Static::NoPing>
connection pool instead.

Because the cluster cannot be pinged, this CxnPool cannot use a short
ping request to determin whether nodes are live or not - it just has to
send requests to the nodes to determine whether they are alive or not.

Most of the time, a dead node will cause the request to fail quickly.
However, in situations where node failure takes time (eg malfunctioning
routers or firewalls), a failure may not be reported until the request
itself times out (see L<Elasticsearch::Cxn/request_timeout>).

Failed nodes will be retried regularly to check if they have recovered.

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

L<Elasticsearch::Role::Cxn/dead_timeout>

=item *

L<Elasticsearch::Role::Cxn/max_dead_timeout>

=back

=head1 METHODS

=head2 C<next_cxn()>

    $cxn = $cxn_pool->next_cxn

Returns the next available node  in round robin fashion - either a live node
which has previously responded successfully, or a previously failed
node which should be retried. If all nodes are dead, it will throw
a C<NoNodes> error.

