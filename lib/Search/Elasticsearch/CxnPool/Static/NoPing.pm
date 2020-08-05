# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::CxnPool::Static::NoPing;

use Moo;
with 'Search::Elasticsearch::Role::CxnPool::Static::NoPing',
    'Search::Elasticsearch::Role::Is_Sync';
use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

1;

__END__

# ABSTRACT: A CxnPool for connecting to a remote cluster without the ability to ping.

=head1 SYNOPSIS

    $e = Search::Elasticsearch->new(
        cxn_pool => 'Static::NoPing'
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

=head1 DESCRIPTION

The L<Static::NoPing|Search::Elasticsearch::CxnPool::Static::NoPing> connection
pool (like the L<Static|Search::Elasticsearch::CxnPool::Static> pool) should be used
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
itself times out (see L<Search::Elasticsearch::Cxn/request_timeout>).

Failed nodes will be retried regularly to check if they have recovered.

This class does L<Search::Elasticsearch::Role::CxnPool::Static::NoPing> and
L<Search::Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 C<nodes>

The list of nodes to use to serve requests.  Can accept a single node,
multiple nodes, and defaults to C<localhost:9200> if no C<nodes> are
specified. See L<Search::Elasticsearch::Role::Cxn/node> for details of the node
specification.

=head2 See also

=over

=item *

L<Search::Elasticsearch::Role::Cxn/request_timeout>

=item *

L<Search::Elasticsearch::Role::Cxn/dead_timeout>

=item *

L<Search::Elasticsearch::Role::Cxn/max_dead_timeout>

=back

=head2 Inherited configuration

From L<Search::Elasticsearch::Role::CxnPool::Static::NoPing>

=over

=item * L<max_retries|Search::Elasticsearch::Role::CxnPool::Static::NoPing/"max_retries">

=back

From L<Search::Elasticsearch::Role::CxnPool>

=over

=item * L<randomize_cxns|Search::Elasticsearch::Role::CxnPool/"randomize_cxns">

=back

=head1 METHODS

=head2 C<next_cxn()>

    $cxn = $cxn_pool->next_cxn

Returns the next available node  in round robin fashion - either a live node
which has previously responded successfully, or a previously failed
node which should be retried. If all nodes are dead, it will throw
a C<NoNodes> error.

=head2 Inherited methods

From L<Search::Elasticsearch::Role::CxnPool::Static::NoPing>

=over

=item * L<should_mark_dead()|Search::Elasticsearch::Role::CxnPool::Static::NoPing/"should_mark_dead()">

=item * L<schedule_check()|Search::Elasticsearch::Role::CxnPool::Static::NoPing/"schedule_check()">

=back

From L<Search::Elasticsearch::Role::CxnPool>

=over

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


