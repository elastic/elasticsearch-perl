package Elasticsearch::CxnPool::Static::NoPing;

use Moo;
with 'Elasticsearch::Role::CxnPool::Static::NoPing',
    'Elasticsearch::Role::Is_Sync';
use Elasticsearch::Util qw(throw);
use namespace::clean;

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
pool (like the L<Static|Elasticsearch::CxnPool::Static> pool) should be used
when your access to the cluster is limited.  However, the C<Static> pool needs
to be able to ping nodes in the cluster, with a C<HEAD /> request.  If you
can't ping your nodes, then you should use the C<Static::NoPing>
connection pool instead.

Because the cluster cannot be pinged, this CxnPool cannot use a short
ping request to determine whether nodes are live or not - it just has to
send requests to the nodes to determine whether they are alive or not.

Most of the time, a dead node will cause the request to fail quickly.
However, in situations where node failure takes time (eg malfunctioning
routers or firewalls), a failure may not be reported until the request
itself times out (see L<Elasticsearch::Cxn/request_timeout>).

Failed nodes will be retried regularly to check if they have recovered.

This class does L<Elasticsearch::Role::CxnPool::Static::NoPing> and
L<Elasticsearch::Role::Is_Sync>.

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

=head2 Inherited configuration

From L<Elasticsearch::Role::CxnPool::Static::NoPing>

=over

=item * L<max_retries|Elasticsearch::Role::CxnPool::Static::NoPing/"max_retries">

=back

From L<Elasticsearch::Role::CxnPool>

=over

=item * L<randomize_cxns|Elasticsearch::Role::CxnPool/"randomize_cxns">

=back

=head1 METHODS

=head2 C<next_cxn()>

    $cxn = $cxn_pool->next_cxn

Returns the next available node  in round robin fashion - either a live node
which has previously responded successfully, or a previously failed
node which should be retried. If all nodes are dead, it will throw
a C<NoNodes> error.

=head2 Inherited methods

From L<Elasticsearch::Role::CxnPool::Static::NoPing>

=over

=item * L<should_mark_dead()|Elasticsearch::Role::CxnPool::Static::NoPing/"should_mark_dead()">

=item * L<schedule_check()|Elasticsearch::Role::CxnPool::Static::NoPing/"schedule_check()">

=back

From L<Elasticsearch::Role::CxnPool>

=item * L<cxn_factory()|Elasticsearch::Role::CxnPool/"cxn_factory()">

=item * L<logger()|Elasticsearch::Role::CxnPool/"logger()">

=item * L<serializer()|Elasticsearch::Role::CxnPool/"serializer()">

=item * L<current_cxn_num()|Elasticsearch::Role::CxnPool/"current_cxn_num()">

=item * L<cxns()|Elasticsearch::Role::CxnPool/"cxns()">

=item * L<seed_nodes()|Elasticsearch::Role::CxnPool/"seed_nodes()">

=item * L<next_cxn_num()|Elasticsearch::Role::CxnPool/"next_cxn_num()">

=item * L<set_cxns()|Elasticsearch::Role::CxnPool/"set_cxns()">

=item * L<request_ok()|Elasticsearch::Role::CxnPool/"request_ok()">

=item * L<request_failed()|Elasticsearch::Role::CxnPool/"request_failed()">

=item * L<should_retry()|Elasticsearch::Role::CxnPool/"should_retry()">

=item * L<should_mark_dead()|Elasticsearch::Role::CxnPool/"should_mark_dead()">

=item * L<cxns_str()|Elasticsearch::Role::CxnPool/"cxns_str()">

=item * L<cxns_seeds_str()|Elasticsearch::Role::CxnPool/"cxns_seeds_str()">

=item * L<retries()|Elasticsearch::Role::CxnPool/"retries()">

=item * L<reset_retries()|Elasticsearch::Role::CxnPool/"reset_retries()">

=back


