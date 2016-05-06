package Search::Elasticsearch::CxnPool::Async::Sniff;

use Moo;
with 'Search::Elasticsearch::Role::CxnPool::Sniff',
    'Search::Elasticsearch::Role::Is_Async';

use Scalar::Util qw(weaken);
use Promises qw(deferred);
use Search::Elasticsearch::Util qw(new_error);

use namespace::clean;
has 'concurrent_sniff' => ( is => 'rw', default => 4 );
has '_current_sniff'   => ( is => 'rw', clearer => '_clear_sniff' );

#===================================
sub next_cxn {
#===================================
    my ( $self, $no_sniff ) = @_;

    return $self->sniff->then( sub { $self->next_cxn('no_sniff') } )
        if $self->next_sniff <= time() && !$no_sniff;

    my $cxns  = $self->cxns;
    my $total = @$cxns;
    my $cxn;

    while ( 0 < $total-- ) {
        $cxn = $cxns->[ $self->next_cxn_num ];
        last if $cxn->is_live;
        undef $cxn;
    }

    my $deferred = deferred;

    if ($cxn) {
        $deferred->resolve($cxn);
    }
    else {
        $deferred->reject(
            new_error(
                "NoNodes",
                "No nodes are available: [" . $self->cxns_seeds_str . ']'
            )
        );
    }
    return $deferred->promise;
}

#===================================
sub sniff {
#===================================
    my $self = shift;

    my $promise;
    if ( $promise = $self->_current_sniff ) {
        return $promise;
    }

    my $deferred   = deferred;
    my $cxns       = $self->cxns;
    my $total      = @$cxns;
    my $done       = 0;
    my $current    = 0;
    my $done_seeds = 0;
    $promise = $self->_current_sniff( $deferred->promise );

    my ( @all, @skipped );

    while ( 0 < $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        if ( $cxn->is_dead ) {
            push @skipped, $cxn;
        }
        else {
            push @all, $cxn;
        }
    }

    push @all, @skipped;
    unless (@all) {
        @all = $self->_seeds_as_cxns;
        $done_seeds++;
    }

    my ( $weak_check_sniff, $cxn );
    my $check_sniff = sub {

        return if $done;
        my ( $cxn, $nodes ) = @_;
        if ( $nodes && $self->parse_sniff($nodes) ) {
            $done++;
            $self->_clear_sniff;
            return $deferred->resolve();
        }

        unless ( @all || $done_seeds++ ) {
            $self->logger->infof("No live nodes available. Trying seed nodes.");
            @all = $self->_seeds_as_cxns;
        }

        if ( my $cxn = shift @all ) {
            return $cxn->sniff->done($weak_check_sniff);
        }
        if ( --$current == 0 ) {
            $self->_clear_sniff;
            $deferred->resolve();
        }
    };
    weaken( $weak_check_sniff = $check_sniff );

    for ( 1 .. $self->concurrent_sniff ) {
        my $cxn = shift(@all) || last;
        $current++;
        $cxn->sniff->done($check_sniff);
    }

    return $promise;
}

#===================================
sub _seeds_as_cxns {
#===================================
    my $self    = shift;
    my $factory = $self->cxn_factory;
    return map { $factory->new_cxn($_) } @{ $self->seed_nodes };
}

1;

# ABSTRACT: An async CxnPool for connecting to a local cluster with a dynamic node list

=head1 SYNOPSIS


    $e = Search::Elasticsearch::Async->new(
        cxn_pool => 'Async::Sniff',
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

=head1 DESCRIPTION

The L<Async::Sniff|Search::Elasticsearch::CxnPool::Async::Sniff> connection
pool should be used when you B<do> have direct access to the Elasticsearch
cluster, eg when your web servers and Elasticsearch servers are on the same
network. The nodes that you specify are used to I<discover> the cluster,
which is then I<sniffed> to find the current list of live nodes that the
cluster knows about.

This sniff process is repeated regularly, or whenever a node fails,
to update the list of healthy nodes.  So if you add more nodes to your
cluster, they will be auto-discovered during a sniff.

If all sniffed nodes fail, then it falls back to sniffing the original
I<seed> nodes that you specified in C<new()>.

For L<HTTP Cxn classes|Search::Elasticsearch::Role::Cxn>, this module
will also dynamically detect the C<max_content_length> which the nodes
in the cluster will accept.

This class does L<Search::Elasticsearch::Role::CxnPool::Sniff> and
L<Search::Elasticsearch::Role::Is_Async>.

=head1 CONFIGURATION

=head2 C<nodes>

The list of nodes to use to discover the cluster.  Can accept a single node,
multiple nodes, and defaults to C<localhost:9200> if no C<nodes> are
specified. See L<Search::Elasticsearch::Role::Cxn/node> for details of the node
specification.

=head2 C<concurrent_sniff>

By default, this module will issue up to 4 concurrent sniff requests in parallel,
depending on how many nodes are known.  The first successful response is used
to set the new list of live nodes.  Set C<concurrent_sniff> to change the
maximum number of concurrent sniff requests.

=head2 See also

=over

=item *

L<Search::Elasticsearch::Role::Cxn/request_timeout>

=item *

L<Search::Elasticsearch::Role::Cxn/sniff_timeout>

=item *

L<Search::Elasticsearch::Role::Cxn/sniff_request_timeout>

=back

=head2 Inherited configuration

From L<Search::Elasticsearch::Role::CxnPool::Sniff>

=over

=item * L<sniff_interval|Search::Elasticsearch::Role::CxnPool::Sniff/"sniff_interval">

=item * L<sniff_max_content_length|Search::Elasticsearch::Role::CxnPool::Sniff/"sniff_max_content_length">

=back

From L<Search::Elasticsearch::Role::CxnPool>

=over

=item * L<randomize_cxns|Search::Elasticsearch::Role::CxnPool/"randomize_cxns">

=back

=head1 METHODS

=head2 C<next_cxn()>

    $cxn_pool->next_cxn
             -> then( sub { my $cxn = shift })

Returns the next available live node (in round robin fashion), or
throws a C<NoNodes> error if no nodes can be sniffed from the cluster.

=head2 C<sniff()>

    $cxn_pool->sniff->then(
        sub { "ok"     },
        sub { "not_ok" }
    );

Sniffs the cluster and returns a promise which is resolved on success, or
rejected on failure.

=head2 Inherited methods

From L<Search::Elasticsearch::Role::CxnPool::Sniff>

=over

=item * L<schedule_check()|Search::Elasticsearch::Role::CxnPool::Sniff/"schedule_check()">

=item * L<parse_sniff()|Search::Elasticsearch::Role::CxnPool::Sniff/"parse_sniff()">

=item * L<should_accept_node()|Search::Elasticsearch::Role::CxnPool::Sniff/"should_accept_node()">

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

