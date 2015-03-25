package Search::Elasticsearch::Client::Direct::Nodes;

use Moo;
with 'Search::Elasticsearch::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('nodes');

1;

__END__

# ABSTRACT: A client for running node-level requests

=head1 DESCRIPTION

This module provides methods to make node-level requests, such as
retrieving node info and stats.

It does L<Search::Elasticsearch::Role::Client::Direct>.

=head1 METHODS


=head2 C<info()>

    $response = $e->nodes->info(
        node_id => $node_id | \@node_ids       # optional
        metric  => $metric  | \@metrics        # optional
    );

The C<info()> method returns static information about the nodes in the
cluster, such as the configured maximum number of file handles, the maximum
configured heap size or the threadpool settings.

Allowed metrics are:
    C<http>,
    C<jvm>,
    C<network>,
    C<os>,
    C<plugin>,
    C<process>,
    C<settings>,
    C<thread_pool>,
    C<transport>

Query string parameters:
    C<flat_settings>,
    C<human>

See the L<node_info docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-info.html>
for more information.

=head2 C<stats()>

    $response = $e->nodes->stats(
        node_id      => $node_id    | \@node_ids       # optional
        metric       => $metric     | \@metrics        # optional
        index_metric => $ind_metric | \@ind_metrics    # optional
    );

The C<stats()> method returns statistics about the nodes in the
cluster, such as the number of currently open file handles, the current
heap memory usage or the current number of threads in use.

Stats can be returned for all nodes, or limited to particular nodes
with the C<node_id> parameter. By default all metrics are returned, but
these can be limited to those specified in the C<metric> parameter.

Allowed metrics are:
    C<_all>,
    C<breaker>,
    C<fs>,
    C<http>,
    C<indices>,
    C<jvm>,
    C<network>,
    C<os>,
    C<process>,
    C<thread_pool>,
    C<transport>

If the C<indices> metric (or C<_all>) is specified, then
L<indices_stats|Search::Elasticsearch::Client::Direct::Indices/indices_stats()>
information is returned on a per-node basis. Which indices stats are
returned can be controlled with the C<index_metric> parameter:

    $response = $e->cluster->node_stats(
        node_id       => 'node_1',
        metric        => ['indices','fs']
        index_metric  => ['docs','fielddata']
    );

Allowed index metrics are:
    C<_all>,
    C<completion>
    C<docs>,
    C<fielddata>,
    C<filter_cache>,
    C<flush>,
    C<get>,
    C<id_cache>,
    C<indexing>,
    C<merge>,
    C<percolate>,
    C<query_cache>,
    C<refresh>,
    C<search>,
    C<segments>,
    C<store>,
    C<warmer>


Query string parameters:
    C<completion_fields>,
    C<fielddata_fields>,
    C<fields>,
    C<groups>,
    C<human>,
    C<level>,
    C<types>

See the L<node_stats docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html>
for more information.

=head2 C<hot_threads()>

    $response = $e->nodes->hot_threads(
        node_id => $node_id | \@node_ids       # optional
    )

The C<hot_threads()> method is a useful tool for diagnosing busy nodes. It
takes a snapshot of which threads are consuming the most CPU.

Query string parameters:
    C<ignore_idle_threads>,
    C<interval>,
    C<snapshots>,
    C<threads>,
    C<type>

See the L<hot_threads docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-hot-threads.html>
for more information.

=head2 C<shutdown()>

    $e->nodes->shutdown(
        node_id => $node_id | \@node_ids    # optional
    );

The C<shutdown()> method is used to shutdown one or more nodes, or the whole
cluster.

Query string parameters:
    C<delay>,
    C<exit>

See the L<shutdown docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-shutdown.html>
for more information.

