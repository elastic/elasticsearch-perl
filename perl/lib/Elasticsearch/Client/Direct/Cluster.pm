#===================================
package Elasticsearch::Client::Direct::Cluster;
#===================================
use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('cluster');

1;

__END__

# ABSTRACT: A client for running cluster-level requests

=head1 DESCRIPTION

This module provides methods to make cluster-level requests, such as
getting and setting cluster-level settings, manually rerouting shards,
and retrieving for monitoring purposes.

It does L<Elasticsearch::Role::Client::Direct>.

=head1 METHODS

=head2 C<health()>

    $response = $e->cluster->health( %qs_params )

The C<health()> method is used to retrieve information about the cluster
health, returning C<red>, C<yellow> or C<green> to indicate the state
of the cluster, indices or shards.

Query string parameters:
    C<level>,
    C<local>,
    C<master_timeout>,
    C<timeout>,
    C<wait_for_active_shards>,
    C<wait_for_nodes>,
    C<wait_for_relocating_shards>,
    C<wait_for_status>

See the L<cluster health docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-health.html>
for more information.


=head2 C<node_info()>

    $response = $e->cluster->node_info(
        node_id => $node_id | \@node_ids       # optional
        metric  => $metric  | \@metrics        # optional
    );

The C<node_info()> method returns static information about the nodes in the
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

See the L<node_info docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-nodes-info.html>
for more information.

=head2 C<node_stats()>

    $response = $e->cluster->node_stats(
        node_id      => $node_id    | \@node_ids       # optional
        metric       => $metric     | \@metrics        # optional
        index_metric => $ind_metric | \@ind_metrics    # optional
    );

The C<node_stats()> method returns statistics about the nodes in the
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
L<indices_stats|Elasticsearch::Client::Direct::Indices/indices_stats()>
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

See the L<node_stats docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-nodes-stats.html>
for more information.

=head2 C<hot_threads()>

    $response = $e->cluster->hot_threads(
        node_id => $node_id | \@node_ids       # optional
    )

The C<hot_threads()> method is a useful tool for diagnosing busy nodes. It
takes a snapshot of which threads are consuming the most CPU.

Query string parameters:
    C<interval>,
    C<snapshots>,
    C<threads>,
    C<type>

See the L<hot_threads docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-nodes-hot-threads.html>
for more information.

=head2 C<get_settings()>

    $response = $e->cluster->get_settings()

The C<get_settings()> method is used to retrieve cluster-wide settings that
have been set with the L</put_settings()> method.

Query string parameters:
    C<flat_settings>

See the L<cluster settings docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-update-settings.html>
for more information.

=head2 C<put_settings()>

    $response = $e->cluster->put_settings( %settings );

The C<put_settings()> method is used to set cluster-wide settings, either
transiently (which don't survive restarts) or permanently (which do survive
restarts).

For instance:

    $response = $e->cluster->put_settings(
        body => {
            transient => { "discovery.zen.minimum_master_nodes" => 5 }
        }
    );

Query string parameters:
    C<flat_settings>

See the L<cluster settings docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-update-settings.html>
 for more information.

=head2 C<state()>

    $response = $e->cluster->state(
        metric => $metric | \@metrics   # optional
        index  => $index  | \@indices   # optional
    );

The C<state()> method returns the current cluster state from the master node,
or from the responding node if C<local> is set to C<true>.

It returns all metrics by default, but these can be limited to any of:
    C<_all>,
    C<blocks>,
    C<index_templates>,
    C<metadata>,
    C<nodes>,
    C<routing_table>

Metrics for indices can be limited to particular indices with the C<index>
parameter.

Query string parameters:
    C<flat_settings>,
    C<local>,
    C<master_timeout>

See the L<cluster state docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-state.html>
for more information.

=head2 C<reroute()>

    $e->cluster->reroute(
        body => { commands }    # required
    );


The C<reroute()> method is used to manually reallocate shards from one
node to another.  The C<body> should contain the C<commands> indicating
which changes should be made. For instance:

    $e->cluster->reroute(
        body => {
            commands => [
                { move => {
                    index     => 'test',
                    shard     => 0,
                    from_node => 'node_1',
                    to_node   => 'node_2
                }},
                { allocate => {
                    index     => 'test',
                    shard     => 1,
                    node      => 'node_3'
                }}
            ]
        }
    );

Query string parameters:
    C<dry_run>,
    C<filter_metadata>

See the L<reroute docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-reroute.html>
for more information.


=head2 C<shutdown()>

    $e->cluster->shutdown(
        node_id => $node_id | \@node_ids    # optional
    );

The C<shutdown()> method is used to shutdown one or more nodes, or the whole
cluster.

Query string parameters:
    C<delay>,
    C<exit>

See the L<shutdown docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-nodes-shutdown.html>
for more information.

=head2 C<put_repository>

    $e->cluster->put_repository(
        repository  => 'repository',        # required
        body        => { defn }             # required
    );

Create a repository for backups.

Query string parameters:
    C<master_timeout>

See the L<"snapshot/restore docs"|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshot.html>
for more information.

=head2 C<get_repository>

    $e->cluster->get_repository(
        repository  => 'repository' | \@repositories    # optional
    );

Retrieve existing repositories.

Query string parameters:
    C<master_timeout>

See the L<"snapshot/restore docs"|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshot.html>
for more information.

=head2 C<delete_repository>

    $e->cluster->delete_repository(
        repository  => 'repository' | \@repositories    # required
    );

Delete repositories by name.

Query string parameters:
    C<master_timeout>,
    C<timeout>

See the L<"snapshot/restore docs"|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshot.html>
for more information.

=head2 C<create_snapshot>

    $e->cluster->create_snapshot(
        repository  => 'repository',     # required
        snapshot    => 'snapshot',       # required,

        body        => { snapshot defn } # optional
    );

Create a snapshot of the whole cluster or individual indices in the named
repository.

Query string parameters:
    C<master_timeout>,
    C<wait_for_completion>

=head2 C<get_snapshot>

    $e->cluster->get_snapshot(
        repository  => 'repository',              # required
        snapshot    => 'snapshot' | \@snapshots   # optional
    );

Retrieve snapshots in the named repository.

Query string parameters:
    C<master_timeout>

See the L<"snapshot/restore docs"|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshot.html>
for more information.

=head2 C<delete_snapshot>

    $e->cluster->delete_snapshot(
        repository  => 'repository',              # required
        snapshot    => 'snapshot' | \@snapshots   # required
    );

Delete snapshots in the named repository.

Query string parameters:
    C<master_timeout>

See the L<"snapshot/restore docs"|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshot.html>
for more information.


=head2 C<restore_snapshot>

    $e->cluster->delete_snapshot(
        repository  => 'repository',              # required
        snapshot    => 'snapshot'                 # required,

        body        => { what to restore }        # optional
    );

Restore a named snapshot.

Query string parameters:
    C<master_timeout>,
    C<wait_for_completion>

See the L<"snapshot/restore docs"|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshot.html>
for more information.


