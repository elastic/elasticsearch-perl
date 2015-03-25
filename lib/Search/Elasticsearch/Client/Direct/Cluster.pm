package Search::Elasticsearch::Client::Direct::Cluster;

use Moo;
with 'Search::Elasticsearch::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('cluster');

sub node_info     { _deprecated( 'node_info',     'info' ) }
sub node_stats    { _deprecated( 'node_stats',    'stats' ) }
sub hot_threads   { _deprecated( 'hot_threads',   'hot_threads' ) }
sub node_shutdown { _deprecated( 'node_shutdown', 'shutdown' ) }

#===================================
sub _deprecated {
#===================================
    my ( $old, $new ) = @_;
    die "The method \$es->cluster->$old() has moved to \$es->nodes->$new()";
}

1;

__END__

# ABSTRACT: A client for running cluster-level requests

=head1 DESCRIPTION

This module provides methods to make cluster-level requests, such as
getting and setting cluster-level settings, manually rerouting shards,
and retrieving for monitoring purposes.

It does L<Search::Elasticsearch::Role::Client::Direct>.

=head1 METHODS

=head2 C<health()>

    $response = $e->cluster->health(
        index   => 'index' | \@indices  # optional
    );

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

See the L<cluster health docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html>
for more information.

=head2 C<stats()>

    $response = $e->cluster->stats(
        node_id => 'node' | \@nodes     # optional
    );

Returns high-level cluster stats, optionally limited to the listed nodes.

Query string parameters:
    C<flat_settings>,
    C<human>

See the L<cluster stats docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-stats.html>
for more information.

=head2 C<get_settings()>

    $response = $e->cluster->get_settings()

The C<get_settings()> method is used to retrieve cluster-wide settings that
have been set with the L</put_settings()> method.

Query string parameters:
    C<flat_settings>,
    C<master_timeout>,
    C<timeout>

See the L<cluster settings docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html>
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

See the L<cluster settings docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html>
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
    C<metadata>,
    C<nodes>,
    C<routing_table>

Metrics for indices can be limited to particular indices with the C<index>
parameter.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<flat_settings>,
    C<ignore_unavailable>,
    C<local>,
    C<master_timeout>

See the L<cluster state docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-state.html>
for more information.

=head2 C<pending_tasks()>

    $response = $e->cluster->pending_tasks();

Returns a list of cluster-level tasks still pending on the master node.

Query string parameters:
    C<local>,
    C<master_timeout>

See the L<pending tasks docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-pending.html>
for more information.

=head2 C<reroute()>

    $e->cluster->reroute(
        body => { commands }
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
    C<explain>,
    C<master_timeout>,
    C<metric>,
    C<timeout>

See the L<reroute docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-reroute.html>
for more information.

