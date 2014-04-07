package Search::Elasticsearch::CxnPool::Async::Static;

use Moo;
with 'Search::Elasticsearch::Role::CxnPool::Static',
    'Search::Elasticsearch::Role::Is_Async';

use Search::Elasticsearch::Util qw(new_error);
use Scalar::Util qw(weaken);
use Promises qw(deferred);
use namespace::clean;

#===================================
sub next_cxn {
#===================================
    my ($self) = @_;

    my $cxns     = $self->cxns;
    my $now      = time();
    my $deferred = deferred;

    my ( %seen, @skipped, $weak_find_cxn );

    my $find_cxn = sub {
        my $total = @$cxns;
        my $found;

        if ( $total > keys %seen ) {

            # we haven't seen all cxns yet
            while ( $total-- ) {
                my $cxn = $cxns->[ $self->next_cxn_num ];
                next if $seen{$cxn}++;

                return $deferred->resolve($cxn)
                    if $cxn->is_live;

                if ( $cxn->next_ping <= time() ) {
                    $found = $cxn;
                    last;
                }

                push @skipped, $cxn;
            }
        }

        if ( $found ||= shift @skipped ) {
            return $found->pings_ok->then(
                sub { $deferred->resolve($found) },    # success
                $weak_find_cxn                         # resolve
            );
        }

        $_->force_ping for @$cxns;

        return $deferred->reject(
            new_error(
                "NoNodes",
                "No nodes are available: [" . $self->cxns_str . ']'
            )
        );

    };
    weaken( $weak_find_cxn = $find_cxn );

    $find_cxn->();
    $deferred->promise;
}

1;

# ABSTRACT: An async CxnPool for connecting to a remote cluster with a static list of nodes.

=head1 SYNOPSIS


    $e = Search::Elasticsearch::Async->new(
        cxn_pool => 'Async::Static'     # default
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

=head1 DESCRIPTION

The L<Async::Static|Search::Elasticsearch::CxnPool::Async::Static> connection
pool, which is the default, should be used when you don't have direct access
to the Elasticsearch cluster, eg when you are accessing the cluster through a
proxy.  It round-robins through the nodes that you specified, and pings each
node before it is used for  the first time, to ensure that it is responding.

If any node fails, then all nodes are pinged before the next request to
ensure that they are still alive and responding.  Failed nodes will be
pinged regularly to check if they have recovered.

This class does L<Search::Elasticsearch::Role::CxnPool::Async::Static> and
L<Search::Elasticsearch::Role::Is_Async>.

=head1 CONFIGURATION

=head2 C<nodes>

The list of nodes to use to serve requests.  Can accept a single node,
multiple nodes, and defaults to C<localhost:9200> if no C<nodes> are
specified. See L<Search::Elasticsearch::Role::Cxn::HTTP/node> for details of the node
specification.

=head2 See also

=over

=item *

L<Search::Elasticsearch::Role::Cxn/request_timeout>

=item *

L<Search::Elasticsearch::Role::Cxn/ping_timeout>

=item *

L<Search::Elasticsearch::Role::Cxn/dead_timeout>

=item *

L<Search::Elasticsearch::Role::Cxn/max_dead_timeout>

=back

=head2 Inherited configuration

From L<Search::Elasticsearch::Role::CxnPool>

=over

=item * L<randomize_cxns|Search::Elasticsearch::Role::CxnPool/"randomize_cxns">

=back


=head1 METHODS

=head2 C<next_cxn()>

    $cxn_pool->next_cxn
             ->then( sub { my $cxn = shift });

Returns the next available live node (in round robin fashion), or
throws a C<NoNodes> error if no nodes respond to ping requests.

=head2 Inherited methods

From L<Search::Elasticsearch::Role::CxnPool::Static>

=over

=item * L<schedule_check()|Search::Elasticsearch::Role::CxnPool::Static/"schedule_check()">

=back

From L<Search::Elasticsearch::Role::CxnPool>

=item * L<cxn_factory()|Search::Elasticsearch::Role::CxnPool/"cxn_factory()">

=item * L<logger()|Search::Elasticsearch::Role::CxnPool/"logger()">

=item * L<serializer()|Search::Elasticsearch::Role::CxnPool/"serializer()">

=item * L<current_cxn_num()|Search::Elasticsearch::Role::CxnPool/"current_cxn_num()">

=item * L<cxns()|Search::Elasticsearch::Role::CxnPool/"cxns()">

=item * L<seed_nodes()|Search::Elasticsearch::Role::CxnPool/"seed_nodes()">

=item * L<next_cxn_num()|Search::Elasticsearch::Role::CxnPool/"next_cxn_num()">

=item * L<set_cxns()|Search::Elasticsearch::Role::CxnPool/"set_cxns()">

=item * L<request_ok()|Search::Elasticsearch::Role::CxnPool/"request_ok()">

=item * L<request_failed()|Search::Elasticsearch::Role::CxnPool/"request_failed()">

=item * L<should_retry()|Search::Elasticsearch::Role::CxnPool/"should_retry()">

=item * L<should_mark_dead()|Search::Elasticsearch::Role::CxnPool/"should_mark_dead()">

=item * L<cxns_str()|Search::Elasticsearch::Role::CxnPool/"cxns_str()">

=item * L<cxns_seeds_str()|Search::Elasticsearch::Role::CxnPool/"cxns_seeds_str()">

=item * L<retries()|Search::Elasticsearch::Role::CxnPool/"retries()">

=item * L<reset_retries()|Search::Elasticsearch::Role::CxnPool/"reset_retries()">

=back
