package Search::Elasticsearch::Client::Direct::Cat;

use Moo;
with 'Search::Elasticsearch::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use Search::Elasticsearch::Util qw(parse_params);
use namespace::clean;
__PACKAGE__->_install_api('cat');

#===================================
sub help {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $params->{help} = 1;
    my $defn = $self->api->{'cat.help'};
    $self->perform_request( $defn, $params );
}

1;

__END__

# ABSTRACT: A client for running cat debugging requests

=head1 DESCRIPTION

The C<cat> API in Elasticsearch provides information about your
cluster and indices in a simple, easy to read text format, intended
for human consumption.

These APIs have a number of parameters in common:

=over

=item * C<help>

Returns help about the API, eg:

    say $e->cat->allocation(help => 1);

=item * C<v>

Includes the column headers in the output:

    say $e->cat->allocation(v => 1);

=item * C<h>

Accepts a list of column names to be output, eg:

    say $e->cat->indices(h => ['health','index']);

=item * C<bytes>

Formats byte-based values as bytes (C<b>), kilobytes (C<k>), megabytes
(C<m>) or gigabytes (C<g>)


=back

It does L<Search::Elasticsearch::Role::Client::Direct>.

=head1 METHODS

=head2 C<help()>

    say $e->cat->help;

Returns the list of supported C<cat> APIs

=head2 C<aliases()>

    say $e->cat->aliases(
        name => 'name' | \@names    # optional
    );

Returns information about index aliases, optionally limited to the specified
index/alias names.

Query string parameters:
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat aliases docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-aliases.html>
for more information.

=head2 C<allocation()>

    say $e->cat->allocation(
        node_id => 'node' | \@nodes    # optional
    );

Provides a snapshot of how shards have located around the cluster and the
state of disk usage.

Query string parameters:
    C<bytes>,
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat allocation docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-allocation.html>
for more information.

=head2 C<count()>

    say $e->cat->count(
        index => 'index' | \@indices    # optional
    );

Provides quick access to the document count of the entire cluster, or
individual indices.

Query string parameters:
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat count docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-count.html>
for more information.

=head2 C<fielddata()>

    say $e->cat->fielddata(
        fields => 'field' | \@fields    # optional
    );

Shows the amount of memory used by each of the specified `fields` (or all
fields) loaded into fielddata.

Query string parameters:
    C<bytes>,
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat fielddata docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-fielddata.html>
for more information.

=head2 C<health()>

    say $e->cat->health();

Provides a snapshot of how shards have located around the cluster and the
state of disk usage.

Query string parameters:
    C<bytes>,
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<ts>,
    C<v>

See the L<cat health docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-health.html>
for more information.

=head2 C<indices()>

    say $e->cat->indices(
        index => 'index' | \@indices    # optional
    );

Provides a summary of index size and health for the whole cluster
or individual indices

Query string parameters:
    C<bytes>,
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<pri>,
    C<v>

See the L<cat indices docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-indices.html>
for more information.

=head2 C<master()>

    say $e->cat->master();

Displays the master’s node ID, bound IP address, and node name.

Query string parameters:
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat master docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-master.html>
for more information.

=head2 C<nodes()>

    say $e->cat->nodes();

Provides a snapshot of all of the nodes in your cluster.

Query string parameters:
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat nodes docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-nodes.html>
for more information.

=head2 C<pending_tasks()>

    say $e->cat->pending_tasks();

Returns any cluster-level tasks which are queued on the master.

Query string parameters:
    C<local>,
    C<master_timeout>,
    C<h>,
    C<help>,
    C<v>

See the L<cat pending-tasks docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-pending-tasks.html>
for more information.

=head2 C<plugins()>

    say $e->cat->plugins();

Returns information about plugins installed on each node.

Query string parameters:
    C<local>,
    C<master_timeout>,
    C<h>,
    C<help>,
    C<v>

See the L<cat plugins docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-plugins.html>
for more information.

=head2 C<recovery()>

    say $e->cat->recovery(
        index => 'index' | \@indices    # optional
    );

Provides a is a view of shard replication. It will show information
anytime data from at least one shard is copying to a different node.
It can also show up on cluster restarts. If your recovery process seems
stuck, try it to see if there’s any movement using C<recovery()>.

Query string parameters:
    C<bytes>,
    C<h>,
    C<help>,
    C<master_timeout>,
    C<v>

See the L<cat recovery docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-recovery.html>
for more information.

=head2 C<segments()>

    say $e->cat->segments(
        index => 'index' | \@indices    # optional
    );

Provides low level information about the segments in the shards of an index.

Query string parameters:
    C<h>,
    C<help>,
    C<v>

See the L<cat shards docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-segments.html>
for more information.

=head2 C<shards()>

    say $e->cat->shards(
        index => 'index' | \@indices    # optional
    );

Provides a detailed view of what nodes contain which shards, the state and
size of each shard.

Query string parameters:
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat shards docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-shards.html>
for more information.

=head2 C<thread_pool()>

    say $e->cat->thread_pool(
        index => 'index' | \@indices    # optional
    );

Shows cluster wide thread pool statistics per node. By default the C<active>,
C<queue> and C<rejected> statistics are returned for the C<bulk>, C<index> and
C<search> thread pools.

Query string parameters:
    C<full_id>,
    C<h>,
    C<help>,
    C<local>,
    C<master_timeout>,
    C<v>

See the L<cat thread_pool docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-thread-pool.html>
for more information.

