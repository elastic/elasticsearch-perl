#===================================
package Elasticsearch::Client::0_90::Direct::Cluster;
#===================================
use Moo;
with 'Elasticsearch::Role::API::0_90';
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
    );

The C<node_info()> method returns static information about the nodes in the
cluster, such as the configured maximum number of file handles, the maximum
configured heap size or the threadpool settings.

Query string parameters:
    C<all>,
    C<clear>,
    C<http>,
    C<jvm>,
    C<network>,
    C<os>,
    C<plugin>,
    C<process>,
    C<settings>,
    C<thread_pool>,
    C<timeout>,
    C<transport>

See the L<node_info docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-nodes-info.html>
for more information.

=head2 C<node_stats()>

    $response = $e->cluster->node_stats(
        node_id => $node_id | \@node_ids       # optional
    );

The C<node_stats()> method returns statistics about the nodes in the
cluster, such as the number of currently open file handles, the current
heap memory usage or the current number of threads in use.

Stats can be returned for all nodes, or limited to particular nodes
with the C<node_id> parameter.
The L<indices_stats|Elasticsearch::Client::Direct::Indices/indices_stats()>
information can also be retrieved on a per-node basis with the C<node_stats()>
method:

    $response = $e->cluster->node_stats(
        node_id => 'node_1',
        indices => 1,
        metric  => 'docs'
    );

Query string parameters:
    C<all>,
    C<clear>,
    C<fields>,
    C<fs>,
    C<http>,
    C<indices>,
    C<jvm>,
    C<network>,
    C<os>,
    C<process>,
    C<thread_pool>,
    C<transport>

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

See the L<cluster settings docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-update-settings.html>
 for more information.

=head2 C<state()>

    $response = $e->cluster->state();

The C<state()> method returns the current cluster state from the master node,
or from the responding node if C<local> is set to C<true>.

Query string parameters:
    C<filter_blocks>,
    C<filter_index_templates>,
    C<filter_indices>,
    C<filter_metadata>,
    C<filter_nodes>,
    C<filter_routing_table>,
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

