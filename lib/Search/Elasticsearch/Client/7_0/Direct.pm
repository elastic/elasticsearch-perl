# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Client::7_0::Direct;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';

use Search::Elasticsearch::Util qw(parse_params is_compat);
use namespace::clean;

sub _namespace {__PACKAGE__}

has 'async_search'         => ( is => 'lazy', init_arg => undef );
has 'autoscaling'          => ( is => 'lazy', init_arg => undef );
has 'cat'                  => ( is => 'lazy', init_arg => undef );
has 'ccr'                  => ( is => 'lazy', init_arg => undef );
has 'cluster'              => ( is => 'lazy', init_arg => undef );
has 'dangling_indices'     => ( is => 'lazy', init_arg => undef );
has 'data_frame_transform_deprecated' => ( is => 'lazy', init_arg => undef );
has 'enrich'               => ( is => 'lazy', init_arg => undef );
has 'eql'                  => ( is => 'lazy', init_arg => undef );
has 'features'             => ( is => 'lazy', init_arg => undef );
has 'graph'                => ( is => 'lazy', init_arg => undef );
has 'ilm'                  => ( is => 'lazy', init_arg => undef );
has 'indices'              => ( is => 'lazy', init_arg => undef );
has 'ingest'               => ( is => 'lazy', init_arg => undef );
has 'license'              => ( is => 'lazy', init_arg => undef );
has 'logstash'             => ( is => 'lazy', init_arg => undef );
has 'migration'            => ( is => 'lazy', init_arg => undef );
has 'ml'                   => ( is => 'lazy', init_arg => undef );
has 'monitoring'           => ( is => 'lazy', init_arg => undef );
has 'nodes'                => ( is => 'lazy', init_arg => undef );
has 'rollup'               => ( is => 'lazy', init_arg => undef );
has 'searchable_snapshots' => ( is => 'lazy', init_arg => undef );
has 'security'             => ( is => 'lazy', init_arg => undef );
has 'snapshot'             => ( is => 'lazy', init_arg => undef );
has 'slm'                  => ( is => 'lazy', init_arg => undef );
has 'sql'                  => ( is => 'lazy', init_arg => undef );
has 'ssl'                  => ( is => 'lazy', init_arg => undef );
has 'tasks'                => ( is => 'lazy', init_arg => undef );
has 'text_structure'       => ( is => 'lazy', init_arg => undef );
has 'transform'            => ( is => 'lazy', init_arg => undef );
has 'watcher'              => ( is => 'lazy', init_arg => undef );
has 'xpack'                => ( is => 'lazy', init_arg => undef );
has 'bulk_helper_class'    => ( is => 'rw' );
has 'scroll_helper_class'  => ( is => 'rw' );
has '_bulk_class'          => ( is => 'lazy' );
has '_scroll_class'        => ( is => 'lazy' );

#===================================
sub _build__bulk_class {
#===================================
    my $self       = shift;
    my $bulk_class = $self->bulk_helper_class
        || 'Client::' . $self->api_version . '::Bulk';
    $self->_build_helper( 'bulk', $bulk_class );
}

#===================================
sub _build__scroll_class {
#===================================
    my $self         = shift;
    my $scroll_class = $self->scroll_helper_class
        || 'Client::' . $self->api_version . '::Scroll';
    $self->_build_helper( 'scroll', $scroll_class );
}

#===================================
sub bulk_helper {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $params->{es} ||= $self;
    $self->_bulk_class->new($params);
}

#===================================
sub scroll_helper {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $params->{es} ||= $self;
    $self->_scroll_class->new($params);
}

#===================================
sub _build_autoscaling          { shift->_build_namespace('Autoscaling') }
sub _build_async_search         { shift->_build_namespace('AsyncSearch') }
sub _build_cat                  { shift->_build_namespace('Cat') }
sub _build_ccr                  { shift->_build_namespace('CCR') }
sub _build_cluster              { shift->_build_namespace('Cluster') }
sub _build_dangling_indices     { shift->_build_namespace('DanglingIndices') }
sub _build_data_frame_transform_deprecated { shift->_build_namespace('DataFrameTransformDeprecated') }
sub _build_enrich               { shift->_build_namespace('Enrich') }
sub _build_eql                  { shift->_build_namespace('Eql') }
sub _build_features             { shift->_build_namespace('Features') }
sub _build_graph                { shift->_build_namespace('Graph') }
sub _build_ilm                  { shift->_build_namespace('ILM') }
sub _build_indices              { shift->_build_namespace('Indices') }
sub _build_ingest               { shift->_build_namespace('Ingest') }
sub _build_license              { shift->_build_namespace('License') }
sub _build_logstash             { shift->_build_namespace('Logstash') }
sub _build_migration            { shift->_build_namespace('Migration') }
sub _build_ml                   { shift->_build_namespace('ML') }
sub _build_monitoring           { shift->_build_namespace('Monitoring') }
sub _build_nodes                { shift->_build_namespace('Nodes') }
sub _build_rollup               { shift->_build_namespace('Rollup') }
sub _build_searchable_snapshots { shift->_build_namespace('SearchableSnapshots') }
sub _build_security             { shift->_build_namespace('Security') }
sub _build_snapshot             { shift->_build_namespace('Snapshot') }
sub _build_slm                  { shift->_build_namespace('Slm') }
sub _build_sql                  { shift->_build_namespace('SQL') }
sub _build_ssl                  { shift->_build_namespace('SSL') }
sub _build_tasks                { shift->_build_namespace('Tasks') }
sub _build_text_structure       { shift->_build_namespace('TextStructure') }
sub _build_transform            { shift->_build_namespace('Transform') }
sub _build_watcher              { shift->_build_namespace('Watcher') }
sub _build_xpack                { shift->_build_namespace('XPack') }
#===================================

__PACKAGE__->_install_api('');

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch 7.x APIs

=head1 SYNOPSIS

Create a client:

    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new(
        client => '7_0::Direct'
    );

Index a doc:

    $e->index(
        index   => 'my_index',
        type    => 'blog_post',
        id      => 123,
        body    => {
            title   => "Elasticsearch clients",
            content => "Interesting content...",
            date    => "2013-09-23"
        }
    );

Get a doc:

    $e->get(
        index   => 'my_index',
        type    => 'my_type',
        id      => 123
    );

Search for docs:

    $results = $e->search(
        index   => 'my_index',
        body    => {
            query => {
                match => {
                    title => "elasticsearch"
                }
            }
        }
    );

Index-level requests:

    $e->indices->create( index => 'my_index' );
    $e->indices->delete( index => 'my_index' )

Ingest pipeline requests:

    $e->ingest->get_pipeline( id => 'apache-logs' );

Cluster-level requests:

    $health = $e->cluster->health;

Node-level requests:

    $info  = $e->nodes->info;
    $stats = $e->nodes->stats;

Snapshot and restore:

    $e->snapshot->create_repository(
        repository => 'my_backups',
        type       => 'fs',
        settings   => {
            location => '/mnt/backups'
        }
    );

    $e->snapshot->create(
        repository => 'my_backups',
        snapshot   => 'backup_2014'
    );

Task management:

    $e->tasks->list;

`cat` debugging:

    say $e->cat->allocation;
    say $e->cat->health;

Cross-cluster replication requests:

    say $e->ccr->follow;

Index lifecycle management requests:

    say $e->ilm->put_lifecycle;

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::7_0::Direct> class provides the
Elasticsearch 7.x compatible client returned by:

    $e = Search::Elasticsearch->new(
        client => "7_0::Direct"  # default
    );

It is intended to be as close as possible to the native REST API that
Elasticsearch uses, so that it is easy to translate the
L<Elasticsearch reference documentation|http://www.elasticsearch/guide>
for an API to the equivalent in this client.

This class provides the methods for L<document CRUD|/DOCUMENT CRUD METHODS>,
L<bulk document CRUD|/BULK DOCUMENT CRUD METHODS> and L<search|/SEARCH METHODS>.
It also provides access to clients for managing L<indices|/indices()>
and the L<cluster|/cluster()>.

=head1 PREVIOUS VERSIONS OF ELASTICSEARCH

This version of the client supports the Elasticsearch 7.0 branch,
which is not backwards compatible with earlier branches.

If you need to talk to a version of Elasticsearch before 7.0.0, please
install one of the following modules:

=over

=item *

L<Search::Elasticsearch::Client::6_0>

=item *

L<Search::Elasticsearch::Client::5_0>

=item *

L<Search::Elasticsearch::Client::2_0>

=item *

L<Search::Elasticsearch::Client::1_0>

=item *

L<Search::Elasticsearch::Client::0_90>

=back

=head1 CONVENTIONS

=head2 Parameter passing

Parameters can be passed to any request method as a list or as a hash
reference. The following two statements are equivalent:

    $e->search( size => 10 );
    $e->search({size => 10});

=head2 Path parameters

Any values that should be included in the URL path, eg C</{index}/{type}>
should be passed as top level parameters:

    $e->search( index => 'my_index', type => 'my_type' );

Alternatively, you can specify a C<path> parameter directly:

    $e->search( path => '/my_index/my_type' );

=head2 Query-string parameters

Any values that should be included in the query string should be passed
as top level parameters:

    $e->search( size => 10 );

If you pass in a C<\%params> hash, then it will be included in the
query string parameters without any error checking. The following:

    $e->search( size => 10, params => { from => 6, size => 6 })

would result in this query string:

    ?from=6&size=10

=head2 Body parameter

The request body should be passed in the C<body> key:

    $e->search(
        body => {
            query => {...}
        }
    );

The body can also be a UTF8-decoded string, which will be converted into
UTF-8 bytes and passed as is:

    $e->indices->analyze( body => "The quick brown fox");

=head2 Boolean parameters

Elasticsearch 7.0.0 and above no longer accepts truthy and falsey values for booleans.  Instead,
it will accept only a JSON C<true> or C<false>, or the string equivalents C<"true"> or C<"false">.

In the Perl client, you can use the following values:

=over

=item * True: C<true>, C<\1>, or a L<JSON::PP::Boolean> object.

=item * False: C<false>, C<\0>, or a L<JSON::PP::Boolean> object.

=back

=head2 Filter path parameter

Any API which returns a JSON body accepts a C<filter_path> parameter
which will filter the JSON down to only the specified paths.  For instance,
if you are running a search request and only want the C<total> hits and
the C<_source> field for each hit (without the C<_id>, C<_index> etc),
you can do:

    $e->search(
        query => {...},
        filter_paths => [ 'hits.total', 'hits.hits._source' ]
    );

=head2 Ignore parameter

Normally, any HTTP status code outside the 200-299 range will result in
an error being thrown.  To suppress these errors, you can specify which
status codes to ignore in the C<ignore> parameter.

    $e->indices->delete(
        index  => 'my_index',
        ignore => 404
    );

This is most useful for
L<Missing|Search::Elasticsearch::Error/Search::Elasticsearch::Error::Missing> errors, which
are triggered by a C<404> status code when some requested resource does
not exist.

Multiple error codes can be specified with an array:

    $e->indices->delete(
        index  => 'my_index',
        ignore => [404,409]
    );

=head1 CONFIGURATION

=head2 C<bulk_helper_class>

The class to use for the L</bulk_helper()> method. Defaults to
L<Search::Elasticsearch::Client::7_0::Bulk>.

=head2 C<scroll_helper_class>

The class to use for the L</scroll_helper()> method. Defaults to
L<Search::Elasticsearch::Client::7_0::Scroll>.

=head1 GENERAL METHODS

=head2 C<info()>

    $info = $e->info

Returns information about the version of Elasticsearch that the responding node
is running.

=head2 C<ping()>

    $e->ping

Pings a node in the cluster and returns C<1> if it receives a C<200>
response, otherwise it throws an error.

=head2 C<indices()>

    $indices_client = $e->indices;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::Indices> object which can be used
for managing indices, eg creating, deleting indices, managing mapping,
index settings etc.

=head2 C<ingest()>

    $ingest_client = $e->ingest;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::Ingest> object which can be used
for managing ingest pipelines.

=head2 C<cluster()>

    $cluster_client = $e->cluster;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::Cluster> object which can be used
for managing the cluster, eg cluster-wide settings and cluster health.

=head2 C<nodes()>

    $node_client = $e->nodes;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::Nodes> object which can be used
to retrieve node info and stats.

=head2 C<snapshot()>

    $snapshot_client = $e->snapshot;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::Snapshot> object which
is used for managing backup repositories and creating and restoring
snapshots.

=head2 C<tasks()>

    $tasks_client = $e->tasks;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::Tasks> object which
is used for accessing the task management API.

=head2 C<cat()>

    $cat_client = $e->cat;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::Cat> object which can be used
to retrieve simple to read text info for debugging and monitoring an
Elasticsearch cluster.

=head2 C<ccr()>

    $ccr_client = $e->ccr;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::CCR> object which can be used
to handle cross-cluster replication requests.


=head2 C<ilm()>

    $ilm_client = $e->ilm;

Returns a L<Search::Elasticsearch::Client::7_0::Direct::ILM> object which can be used
to handle index lifecycle management requests.

=head1 DOCUMENT CRUD METHODS

These methods allow you to perform create, index, update and delete requests
for single documents:

=head2 C<index()>

    $response = $e->index(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # optional, otherwise auto-generated

        body    => { document }         # required
    );

The C<index()> method is used to index a new document or to reindex
an existing document.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<if_primary_term>,
    C<if_seq_no>,
    C<op_type>,
    C<parent>,
    C<pipeline>,
    C<refresh>,
    C<routing>,
    C<timeout>,
    C<version>,
    C<version_type>,
    C<wait_for_active_shards>

See the L<index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html>
for more information.

=head2 C<create()>

    $response = $e->create(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # required

        body    => { document }         # required
    );

The C<create()> method works exactly like the L</index()> method, except
that it will throw a C<Conflict> error if a document with the same
C<index>, C<type> and C<id> already exists.

Query string parameters:
    C<consistency>,
    C<error_trace>,
    C<human>,
    C<op_type>,
    C<parent>,
    C<refresh>,
    C<routing>,
    C<timeout>,
    C<version>,
    C<version_type>

See the L<create docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-create.html>
for more information.

=head2 C<get()>

    $response = $e->get(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # required
    );

The C<get()> method will retrieve the document with the specified
C<index>, C<type> and C<id>, or will throw a C<Missing> error.

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<error_trace>,
    C<human>,
    C<parent>,
    C<preference>,
    C<realtime>,
    C<refresh>,
    C<routing>,
    C<stored_fields>,
    C<version>,
    C<version_type>

See the L<get docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html>
for more information.

=head2 C<get_source()>

    $response = $e->get_source(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # required
    );

The C<get_source()> method works just like the L</get()> method except that
it returns just the C<_source> field (the value of the C<body> parameter
in the L</index()> method) instead of returning the C<_source> field
plus the document metadata, ie the C<_index>, C<_type> etc.

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<error_trace>,
    C<human>,
    C<parent>,
    C<preference>,
    C<realtime>,
    C<refresh>,
    C<routing>,
    C<version>,
    C<version_type>

See the L<get_source docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html>
for more information.

=head2 C<exists()>

    $response = $e->exists(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # required
    );

The C<exists()> method returns C<1> if a document with the specified
C<index>, C<type> and C<id> exists, or an empty string if it doesn't.

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<error_trace>,
    C<human>,
    C<parent>,
    C<preference>,
    C<realtime>,
    C<refresh>,
    C<routing>,
    C<version>,
    C<version_type>

See the L<exists docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html>
for more information.

=head2 C<delete()>

    $response = $e->delete(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # required
    );

The C<delete()> method will delete the document with the specified
C<index>, C<type> and C<id>, or will throw a C<Missing> error.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<if_primary_term>,
    C<if_seq_no>,
    C<parent>,
    C<refresh>,
    C<routing>,
    C<timeout>,
    C<version>,
    C<version_type>,
    C<wait_for_active_shards>

See the L<delete docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html>
for more information.

=head2 C<update()>

    $response = $e->update(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # required

        body    => { update }           # required
    );

The C<update()> method updates a document with the corresponding
C<index>, C<type> and C<id> if it exists. Updates can be performed either by:

=over

=item * providing a partial document to be merged in to the existing document:

    $response = $e->update(
        ...,
        body => {
            doc => { new_field => 'new_value'},
        }
    );

=item * with an inline script:

    $response = $e->update(
        ...,
        body => {
            script => {
                source => "ctx._source.counter += incr",
                params => { incr => 6 }
            }
        }
    );

=item * with an indexed script:

    $response = $e->update(
        ...,
        body => {
            script => {
                id     => $id,
                lang   => 'painless',
                params => { incr => 6 }
            }
        }
    );

See L<indexed scripts|https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#_indexed_scripts>
for more information.

=item * with a script stored as a file:

    $response = $e->update(
        ...,
        body => {
            script => {
                file   => 'counter',
                lang   => 'painless',
                params => { incr => 6 }
            }
        }
    );

See L<scripting docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html>
for more information.

=back

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<error_trace>,
    C<fields>,
    C<human>,
    C<if_primary_term>,
    C<if_seq_no>,
    C<lang>,
    C<parent>,
    C<refresh>,
    C<retry_on_conflict>,
    C<routing>,
    C<timeout>,
    C<version>,
    C<version_type>,
    C<wait_for_active_shards>

See the L<update docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html>
for more information.

=head2 C<termvectors()>

    $results = $e->termvectors(
        index   => $index,          # required
        type    => $type,           # required

        id      => $id,             # optional
        body    => {...}            # optional
    )

The C<termvectors()> method retrieves term and field statistics, positions,
offsets and payloads for the specified document, assuming that termvectors
have been enabled.

Query string parameters:
    C<error_trace>,
    C<field_statistics>,
    C<fields>,
    C<human>,
    C<offsets>,
    C<parent>,
    C<payloads>,
    C<positions>,
    C<preference>,
    C<realtime>,
    C<routing>,
    C<term_statistics>,
    C<version>,
    C<version_type>

See the L<termvector docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-termvectors.html>
for more information.

=head1 BULK DOCUMENT CRUD METHODS

The bulk document CRUD methods are used for running multiple CRUD actions
within a single request.  By reducing the number of network requests
that need to be made, bulk requests greatly improve performance.

=head2 C<bulk()>

    $response = $e->bulk(
        index   => 'index_name',        # required if type specified
        type    => 'type_name',         # optional

        body    => [ actions ]          # required
    );

See L<Search::Elasticsearch::Client::7_0::Bulk> and L</bulk_helper()> for a helper module that makes
bulk indexing simpler to use.

The C<bulk()> method can perform multiple L</index()>, L</create()>,
L</delete()> or L</update()> actions with a single request. The C<body>
parameter expects an array containing the list of actions to perform.

An I<action> consists of an initial metadata hash ref containing the action
type, plus the associated metadata, eg :

    { delete => { _index => 'index', _type => 'type', _id => 123 }}

The C<index> and C<create> actions then expect a hashref containing
the document itself:

    { create => { _index => 'index', _type => 'type', _id => 123 }},
    { title => "A newly created document" }

And the C<update> action expects a hashref containing the update commands,
eg:

    { update => { _index => 'index', _type => 'type', _id => 123 }},
    { script => "ctx._source.counter+=1" }


Each action can include the same parameters that you would pass to
the equivalent L</index()>, L</create()>, L</delete()> or L</update()>
request, except that C<_index>, C<_type> and C<_id> must be specified with
the preceding underscore. All other parameters can be specified with or
without the underscore.

For instance:

    $response = $e->bulk(
        index   => 'index_name',        # default index name
        type    => 'type_name',         # default type name
        body    => [

            # create action
            { create => {
                _index => 'not_the_default_index',
                _type  => 'not_the_default_type',
                _id    => 123
            }},
            { title => 'Foo' },

            # index action
            { index => { _id => 124 }},
            { title => 'Foo' },

            # delete action
            { delete => { _id => 126 }},

            # update action
            { update => { _id => 126 }},
            { script => "ctx._source.counter+1" }
        ]
    );

Each action is performed separately. One failed action will not
cause the others to fail as well.

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<error_trace>,
    C<fields>,
    C<human>,
    C<pipeline>,
    C<refresh>,
    C<routing>,
    C<timeout>,
    C<wait_for_active_shards>

See the L<bulk docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html>
for more information.

=head2 C<bulk_helper()>

    $bulk_helper = $e->bulk_helper( @args );

Returns a new instance of the class specified in the L</bulk_helper_class>,
which defaults to L<Search::Elasticsearch::Client::7_0::Bulk>.

=head2 C<mget()>

    $results = $e->mget(
        index   => 'default_index',     # optional, required when type specified
        type    => 'default_type',      # optional

        body    => { docs or ids }      # required
    );

The C<mget()> method will retrieve multiple documents with a single request.
The C<body> consists of an array of documents to retrieve:

    $results = $e->mget(
        index   => 'default_index',
        type    => 'default_type',
        body    => {
            docs => [
                { _id => 1},
                { _id => 2, _type => 'not_the_default_type' }
            ]
        }
    );

You can also pass any of the other parameters that the L</get()> request
accepts.

If you have specified an C<index> and C<type>, you can just include the
C<ids> of the documents to retrieve:

    $results = $e->mget(
        index   => 'default_index',
        type    => 'default_type',
        body    => {
            ids => [ 1, 2, 3]
        }
    );

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<error_trace>,
    C<human>,
    C<preference>,
    C<realtime>,
    C<refresh>,
    C<routing>,
    C<stored_fields>

See the L<mget docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html>
for more information.

=head2 C<mtermvectors()>

    $results = $e->mtermvectors(
        index   => $index,          # required if type specified
        type    => $type,           # optional

        body    => { }              # optional
    )

Runs multiple L</termvector()> requests in a single request, eg:

    $results = $e->mtermvectors(
        index   => 'test',
        body    => {
            docs => [
                { _type => 'test', _id => 1, fields => ['text'] },
                { _type => 'test', _id => 2, payloads => 1 },
            ]
        }
    );

Query string parameters:
    C<error_trace>,
    C<field_statistics>,
    C<fields>,
    C<human>,
    C<ids>,
    C<offsets>,
    C<parent>,
    C<payloads>,
    C<positions>,
    C<preference>,
    C<realtime>,
    C<routing>,
    C<term_statistics>,
    C<version>,
    C<version_type>

See the L<mtermvectors docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-termvectors.html>
for more information.

=head1 SEARCH METHODS

The search methods are used for querying documents in one, more or all indices
and of one, more or all types:

=head2 C<search()>

    $results = $e->search(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional

        body    => { search params }        # optional
    );

The C<search()> method searches for matching documents in one or more
indices.  It is just as easy to search a single index as it is to search
all the indices in your cluster.  It can also return
L<aggregations|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html>
L<highlighted snippets|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-highlighting.html>
and L<did-you-mean|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters-phrase.html>
or L<search-as-you-type|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters-completion.html>
suggestions.

The I<lite> L<version of search|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-uri-request.html>
allows you to specify a query string in the C<q> parameter, using the
Lucene query string syntax:

    $results = $e->search( q => 'title:(elasticsearch clients)');

However, the preferred way to search is by using the
L<Query DSL|http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html>
to create a query, and passing that C<query> in the
L<request body|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html>:

    $results = $e->search(
        body => {
            query => {
                match => { title => 'Elasticsearch clients'}
            }
        }
    );

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<allow_no_indices>,
    C<allow_partial_search_results>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<batched_reduce_size>,
    C<default_operator>,
    C<df>,
    C<docvalue_fields>,
    C<error_trace>,
    C<expand_wildcards>,
    C<explain>,
    C<from>,
    C<human>,
    C<ignore_throttled>,
    C<ignore_unavailable>,
    C<lenient>,
    C<max_concurrent_shard_requests>,
    C<pre_filter_shard_size>,
    C<preference>,
    C<q>,
    C<request_cache>,
    C<rest_total_hits_as_int>,
    C<routing>,
    C<scroll>,
    C<search_type>,
    C<seq_no_primary_term>,
    C<size>,
    C<sort>,
    C<stats>,
    C<stored_fields>,
    C<suggest_field>,
    C<suggest_mode>,
    C<suggest_size>,
    C<suggest_text>,
    C<terminate_after>,
    C<timeout>,
    C<track_scores>,
    C<track_total_hits>,
    C<typed_keys>,
    C<version>

See the L<search reference|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html>
for more information.

Also see L<Search::Elasticsearch::Transport/send_get_body_as>.

=head2 C<count()>

    $results = $e->count(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional

        body    => { query }                # optional
    )

The C<count()> method returns the total count of all documents matching the
query:

    $results = $e->count(
        body => {
            query => {
                match => { title => 'Elasticsearch clients' }
            }
        }
    );

Query string parameters:
    C<allow_no_indices>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<default_operator>,
    C<df>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_throttled>,
    C<ignore_unavailable>,
    C<lenient>,
    C<lowercase_expanded_terms>
    C<min_score>,
    C<preference>,
    C<q>,
    C<routing>,
    C<terminate_after>

See the L<count docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-count.html>
for more information.

=head2 C<search_template()>

    $results = $e->search_template(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional

        body    => { search params }        # required
    );

Perform a search by specifying a template (either predefined or defined
within the C<body>) and parameters to use with the template, eg:

    $results = $e->search_template(
        body => {
            source => {
                query => {
                    match => {
                        "{{my_field}}" => "{{my_value}}"
                    }
                },
                size => "{{my_size}}"
            },
            params => {
                my_field => 'foo',
                my_value => 'bar',
                my_size  => 6
            }
        }
    );

See the L<search template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html>
for more information.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<explain>,
    C<human>,
    C<ignore_throttled>,
    C<ignore_unavailable>,
    C<preference>,
    C<profile>,
    C<rest_total_hits_as_int>,
    C<scroll>,
    C<search_type>,
    C<typed_keys>

=head2 C<render_search_template()>

    $response = $e->render_search_template(
        id   => 'id',           # optional
        body => { template }    # optional
    );

Renders the template, filling in the passed-in parameters and returns the resulting JSON, eg:

    $results = $e->render_search_template(
        body => {
            source => {
                query => {
                    match => {
                        "{{my_field}}" => "{{my_value}}"
                    }
                },
                size => "{{my_size}}"
            },
            params => {
                my_field => 'foo',
                my_value => 'bar',
                my_size  => 6
            }
        }
    );

See the L<search template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html>
for more information.

=head2 C<scroll()>

    $results = $e->scroll(
        scroll      => '1m',
        body => {
            scroll_id   => $id
        }
    );

When a L</search()> has been performed with the
C<scroll> parameter, the C<scroll()>
method allows you to keep pulling more results until the results
are exhausted.

See L</scroll_helper()> and L<Search::Elasticsearch::Client::7_0::Scroll> for a helper utility
which makes managing scroll requests much easier.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<rest_total_hits_as_int>,
    C<scroll>,
    C<scroll_id>

See the L<scroll docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html>
and the L<search_type docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search.html/search-request-search-type.html>
for more information.

=head2 C<clear_scroll()>

    $response = $e->clear_scroll(
        body => {
            scroll_id => $id | \@ids    # required
        }
    );

The C<clear_scroll()> method can clear unfinished scroll requests, freeing
up resources on the server.

=head2 C<scroll_helper()>

    $scroll_helper = $e->scroll_helper( @args );

Returns a new instance of the class specified in the L</scroll_helper_class>,
which defaults to L<Search::Elasticsearch::Client::7_0::Scroll>.


=head2 C<msearch()>

    $results = $e->msearch(
        index   => 'default_index' | \@indices,     # optional
        type    => 'default_type'  | \@types,       # optional

        body    => [ searches ]                     # required
    );

The C<msearch()> method allows you to perform multiple searches in a single
request.  Similar to the L</bulk()> request, each search request in the
C<body> consists of two hashes: the metadata hash then the search request
hash (the same data that you'd specify in the C<body> of a L</search()>
request).  For instance:

    $results = $e->msearch(
        index   => 'default_index',
        type    => ['default_type_1', 'default_type_2'],
        body => [
            # uses defaults
            {},
            { query => { match_all => {} }},

            # uses a custom index
            { index => 'not_the_default_index' },
            { query => { match_all => {} }}
        ]
    );

Query string parameters:
    C<error_trace>,
    C<human>,
    C<max_concurrent_searches>,
    C<max__concurrent_shard_requests>,
    C<pre_filter_shard_size>,
    C<rest_total_hits_as_int>,
    C<search_type>,
    C<typed_keys>

See the L<msearch docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html>
for more information.

=head2 C<msearch_template()>

    $results = $e->msearch_template(
        index   => 'default_index' | \@indices,     # optional
        type    => 'default_type'  | \@types,       # optional

        body    => [ search_templates ]             # required
    );

The C<msearch_template()> method allows you to perform multiple searches in a single
request using search templates.  Similar to the L</bulk()> request, each search
request in the C<body> consists of two hashes: the metadata hash then the search request
hash (the same data that you'd specify in the C<body> of a L</search()>
request).  For instance:

    $results = $e->msearch(
        index   => 'default_index',
        type    => ['default_type_1', 'default_type_2'],
        body => [
            # uses defaults
            {},
            { source => { query => { match => { user => "{{user}}" }}} params => { user => 'joe' }},

            # uses a custom index
            { index => 'not_the_default_index' },
            { source => { query => { match => { user => "{{user}}" }}} params => { user => 'joe' }},
        ]
    );

Query string parameters:
    C<error_trace>,
    C<human>,
    C<max_concurrent_searches>,
    C<rest_total_hits_as_int>,
    C<search_type>,
    C<typed_keys>

See the L<msearch-template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html>
for more information.

=head2 C<explain()>

    $response = $e->explain(
        index   => 'my_index',  # required
        type    => 'my_type',   # required
        id      => 123,         # required

        body    => { search }   # required
    );

The C<explain()> method explains why the specified document did or
did not match a query, and how the relevance score was calculated.
For instance:

    $response = $e->explain(
        index   => 'my_index',
        type    => 'my_type',
        id      => 123,
        body    => {
            query => {
                match => { title => 'Elasticsearch clients' }
            }
        }
    );

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<default_operator>,
    C<df>,
    C<error_trace>,
    C<human>,
    C<lenient>,
    C<parent>,
    C<preference>,
    C<q>,
    C<routing>,
    C<stored_fields>

See the L<explain docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html>
for more information.

=head2 C<field_caps()>

    $response = $e->field_caps(
        index   => 'index'   | \@indices,   # optional
        body    => { filters }              # optional
    );

The C<field-caps> API returns field types and abilities, merged across indices.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<fields>,
    C<human>,
    C<ignore_unavailable>

See the L<field-caps docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-field-caps.html>
for more information.

=head2 C<search_shards()>

    $response = $e->search_shards(
        index   => 'index' | \@indices,     # optional
    )

The C<search_shards()> method returns information about which shards on
which nodes will execute a search request.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<local>,
    C<preference>,
    C<routing>

See the L<search-shards docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-shards.html>
for more information.

=head2 C<rank_eval()>

    $result = $e->rank_eval(
        index   => 'index' | \@indices,     # optional
        body    => {...}                    # required
    );

The ranking evaluation API provides a way to execute test cases to determine whether search results
are improving or worsening.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<filter_path>,
    C<human>,
    C<ignore_unavailable>

See the L<rank-eval docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/search-rank-eval.html>
for more information.

=head1 CRUD-BY-QUERY METHODS

=head2 C<delete_by_query()>

    $response = $e->delete_by_query(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional,
        body    => { delete-by-query }      # required
    );

The C<delete_by_query()> method deletes all documents which match the specified query.

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<allow_no_indices>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<conflicts>,
    C<default_operator>,
    C<df>,
    C<error_trace>,
    C<expand_wildcards>,
    C<from>,
    C<human>,
    C<ignore_unavailable>,
    C<lenient>,
    C<preference>,
    C<q>,
    C<refresh>,
    C<request_cache>,
    C<requests_per_second>,
    C<routing>,
    C<scroll>,
    C<scroll_size>,
    C<search_timeout>,
    C<search_type>,
    C<size>,
    C<slices>,
    C<sort>,
    C<stats>,
    C<terminate_after>,
    C<version>,
    C<timeout>,
    C<wait_for_active_shards>,
    C<wait_for_completion>

See the L<delete-by-query docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete-by-query.html>
for more information.

=head2 C<delete_by_query_rethrottle()>

    $response = $e->delete_by_query_rethrottle(
        task_id             => 'id'         # required
        requests_per_second => num
    );

The C<delete_by_query_rethrottle()> API is used to dynamically update the throtting
of an existing delete-by-query request, identified by C<task_id>.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<requests_per_second>

See the L<delete-by-query-rethrottle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete-by-query.html>
for more information.

=head2 C<reindex()>

    $response = $e->reindex(
        body => { reindex }     # required
    );

The C<reindex()> API is used to index documents from one index or multiple indices
to a new index.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<refresh>,
    C<requests_per_second>,
    C<slices>,
    C<timeout>,
    C<wait_for_active_shards>,
    C<wait_for_completion>

See the L<reindex docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html>
for more information.

=head2 C<reindex_rethrottle()>

    $response = $e->delete_by_query_rethrottle(
        task_id => 'id',            # required
        requests_per_second => num
    );

The C<reindex_rethrottle()> API is used to dynamically update the throtting
of an existing reindex request, identified by C<task_id>.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<requests_per_second>

See the L<reindex-rethrottle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html>
for more information.


=head2 C<update_by_query()>

    $response = $e->update_by_query(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional,
        body    => { update-by-query }      # optional
    );

The C<update_by_query()> API is used to bulk update documents from one index or
multiple indices using a script.

Query string parameters:
    C<_source>,
    C<_source_excludes>,
    C<_source_includes>,
    C<allow_no_indices>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<conflicts>,
    C<default_operator>,
    C<df>,
    C<error_trace>,
    C<expand_wildcards>,
    C<from>,
    C<human>,
    C<ignore_unavailable>,
    C<lenient>,
    C<pipeline>,
    C<preference>,
    C<q>,
    C<refresh>,
    C<request_cache>,
    C<requests_per_second>,
    C<routing>,
    C<scroll>,
    C<scroll_size>,
    C<search_timeout>,
    C<search_type>,
    C<size>,
    C<slices>,
    C<sort>,
    C<stats>,
    C<terminate_after>,
    C<timeout>,
    C<version>,
    C<version_type>,
    C<wait_for_active_shards>,
    C<wait_for_completion>

See the L<update_by_query docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update-by-query.html>
for more information.

=head2 C<update_by_query_rethrottle()>

    $response = $e->update_by_query_rethrottle(
        task_id             => 'id'         # required
        requests_per_second => num
    );

The C<update_by_query_rethrottle()> API is used to dynamically update the throtting
of an existing update-by-query request, identified by C<task_id>.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<requests_per_second>

See the L<update-by-query-rethrottle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update-by-query.html>
for more information.


=head1 INDEXED SCRIPT METHODS

Elasticsearch allows you to store scripts in the cluster state
and reference them by id. The methods to manage indexed scripts are as follows:

=head2 C<put_script()>

    $result  = $e->put_script(
        id      => 'id',       # required
        context => $context,   # optional
        body    => { script }  # required
    );

The C<put_script()> method is used to store a script in the cluster state. For instance:

    $result  = $e->put_scripts(
        id   => 'hello_world',
        body => {
          script => {
            lang   => 'painless',
            source => q(return "hello world")
          }
        }
    );

Query string parameters:
    C<error_trace>,
    C<human>


See the L<indexed scripts docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#_indexed_scripts> for more.

=head2 C<get_script()>

    $script = $e->get_script(
        id   => 'id',       # required
    );

Retrieve the indexed script from the cluster state.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>

See the L<indexed scripts docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#_indexed_scripts> for more.

=head2 C<delete_script()>

    $script = $e->delete_script(
        id   => 'id',       # required
    );

Delete the indexed script from the cluster state.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>

See the L<indexed scripts docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#_indexed_scripts> for more.

=head2 C<scripts_painless_execute()>

    $result = $e->scripts_painless_execute(
        body => {...}   # required
    );

The Painless execute API allows an arbitrary script to be executed and a result to be returned.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<painless execution docs|https://www.elastic.co/guide/en/elasticsearch/painless/current/painless-execute-api.html> for more.

