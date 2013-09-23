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

=head1 METHODS

=head2 C<health()>

    $response = $e->cluster->health( %qs_params )

The C<health()> method is used to retrieve information about the cluster
health, returning C<red>, C<yellow> or C<green> to indicate the state
of the cluster, indices or shards.

Query string parameters:
    L<level|Elasticsearch::Util::API::QS/level>,
    L<local|Elasticsearch::Util::API::QS/local>,
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>,
    L<wait_for_active_shards|Elasticsearch::Util::API::QS/wait_for_active_shards>,
    L<wait_for_nodes|Elasticsearch::Util::API::QS/wait_for_nodes>,
    L<wait_for_relocating_shards|Elasticsearch::Util::API::QS/wait_for_relocating_shards>,
    L<wait_for_status|Elasticsearch::Util::API::QS/wait_for_status>

See the L<cluster health docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-health/>
for more information.


=head2 C<node_info()>

    $response = $e->cluster->node_info(
        node_id => $node_id | \@node_ids       # optional
    );

The C<node_info()> method returns static information about the nodes in the
cluster, such as the configured maximum number of file handles, the maximum
configured heap size or the threadpool settings.

Query string parameters:
    L<all|Elasticsearch::Util::API::QS/all>,
    L<clear|Elasticsearch::Util::API::QS/clear>,
    L<http|Elasticsearch::Util::API::QS/http>,
    L<jvm|Elasticsearch::Util::API::QS/jvm>,
    L<network|Elasticsearch::Util::API::QS/network>,
    L<os|Elasticsearch::Util::API::QS/os>,
    L<plugin|Elasticsearch::Util::API::QS/plugin>,
    L<process|Elasticsearch::Util::API::QS/process>,
    L<settings|Elasticsearch::Util::API::QS/settings>,
    L<thread_pool|Elasticsearch::Util::API::QS/thread_pool>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>,
    L<transport|Elasticsearch::Util::API::QS/transport>

See the L<node_info docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-info/>
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
    L<all|Elasticsearch::Util::API::QS/all>,
    L<clear|Elasticsearch::Util::API::QS/clear>,
    L<fields|Elasticsearch::Util::API::QS/fields>,
    L<fs|Elasticsearch::Util::API::QS/fs>,
    L<http|Elasticsearch::Util::API::QS/http>,
    L<indices|Elasticsearch::Util::API::QS/indices>,
    L<jvm|Elasticsearch::Util::API::QS/jvm>,
    L<network|Elasticsearch::Util::API::QS/network>,
    L<os|Elasticsearch::Util::API::QS/os>,
    L<process|Elasticsearch::Util::API::QS/process>,
    L<thread_pool|Elasticsearch::Util::API::QS/thread_pool>,
    L<transport|Elasticsearch::Util::API::QS/transport>

See the L<node_stats docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-stats/>
for more information.

=head2 C<hot_threads()>

    $response = $e->cluster->hot_threads(
        node_id => $node_id | \@node_ids       # optional
    )

The C<hot_threads()> method is a useful tool for diagnosing busy nodes. It
takes a snapshot of which threads are consuming the most CPU.

Query string parameters:
    L<interval|Elasticsearch::Util::API::QS/interval>,
    L<snapshots|Elasticsearch::Util::API::QS/snapshots>,
    L<threads|Elasticsearch::Util::API::QS/threads>,
    L<type|Elasticsearch::Util::API::QS/type>

See the L<hot_threads docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-hot-threads/>
for more information.

=head2 C<get_settings()>

    $response = $e->cluster->get_settings()

The C<get_settings()> method is used to retrieve cluster-wide settings that
have been set with the L</put_settings()> method.

See the L<cluster settings docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-update-settings/>
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

See the L<cluster settings docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-update-settings/>
 for more information.

=head2 C<state()>

    $response = $e->cluster->state();

The C<state()> method returns the current cluster state from the master node,
or from the responding node if C<local> is set to C<true>.

Query string parameters:
    L<filter_blocks|Elasticsearch::Util::API::QS/filter_blocks>,
    L<filter_index_templates|Elasticsearch::Util::API::QS/filter_index_templates>,
    L<filter_indices|Elasticsearch::Util::API::QS/filter_indices>,
    L<filter_metadata|Elasticsearch::Util::API::QS/filter_metadata>,
    L<filter_nodes|Elasticsearch::Util::API::QS/filter_nodes>,
    L<filter_routing_table|Elasticsearch::Util::API::QS/filter_routing_table>,
    L<local|Elasticsearch::Util::API::QS/local>,
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>

See the L<cluster state docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-state/>
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
    L<dry_run|Elasticsearch::Util::API::QS/dry_run>,
    L<filter_metadata|Elasticsearch::Util::API::QS/filter_metadata>

See the L<reroute docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-reroute/>
for more information.


=head2 C<shutdown()>

    $e->cluster->shutdown(
        node_id => $node_id | \@node_ids    # optional
    );

The C<shutdown()> method is used to shutdown one or more nodes, or the whole
cluster.

Query string parameters:
    L<delay|Elasticsearch::Util::API::QS/delay>,
    L<exit|Elasticsearch::Util::API::QS/exit>

See the L<shutdown docs|http://www.elasticsearch.org/guide/reference/api/admin-cluster-nodes-shutdown/>
for more information.

