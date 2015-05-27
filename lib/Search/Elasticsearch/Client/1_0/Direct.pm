package Search::Elasticsearch::Client::1_0::Direct;

sub _namespace {__PACKAGE__}

use Moo;
with 'Search::Elasticsearch::Role::API::1_0';
with 'Search::Elasticsearch::Role::Client::Direct';
with 'Search::Elasticsearch::Role::Client::Direct::Main';

__PACKAGE__->_install_api('');

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch 1.x APIs

=head1 SYNOPSIS

Create a client:

    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new(
        client => '1_0::Direct'          # default
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

`cat` debugging:

    say $e->cat->allocation;
    say $e->cat->health;

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::1_0::Direct> class provides the default
client that is returned by:

    $e = Search::Elasticsearch->new;

It is intended to be as close as possible to the native REST API that
Elasticsearch uses, so that it is easy to translate the
L<Elasticsearch reference documentation|http://www.elasticsearch/guide>
for an API to the equivalent in this client.

This class provides the methods for L<document CRUD|/DOCUMENT CRUD METHODS>,
L<bulk document CRUD|/BULK DOCUMENT CRUD METHODS> and L<search|/SEARCH METHODS>.
It also provides access to clients for managing L<indices|/indices()>
and the L<cluster|/cluster()>.

=head1 BACKWARDS COMPATIBILITY AND ELASTICSEARCH 0.90.x

This version of the client supports the Elasticsearch 1.0 branch by
default, which is not backwards compatible with the 0.90 branch.

If you need to talk to a version of Elasticsearch before 1.0.0,
please use L<Search::Elasticsearch::Client::0_90::Direct> as follows:

    $es = Search::Elasticsearch->new(
        client => '0_90::Direct'
    );

=head1 ELASTICSEARCH 2.x

A client compatible with the as-yet-unreleased version 2.x of Elasticsearch is
available as:

    $es = Search::Elasticsearch->new(
        client => '2_0::Direct'
    );

This will become the new default client once Elasticsearch 2.0.0 has been released.

See L<Search::Elasticsearch::Client::2_0::Direct> for docs about the 2.x compatible
client.

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

    $e->search( size => 10, params => { from => 5, size => 5 })

would result in this query string:

    ?from=5&size=10

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

This parameter was added in Elasticsearch 1.6.0.

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
L<Search::Elasticsearch::Bulk>.

=head2 C<scroll_helper_class>

The class to use for the L</scroll_helper()> method. Defaults to
L<Search::Elasticsearch::Scroll>.

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

Returns an L<Search::Elasticsearch::Client::1_0::Direct::Indices> object which can be used
for managing indices, eg creating, deleting indices, managing mapping,
index settings etc.

=head2 C<cluster()>

    $cluster_client = $e->cluster;

Returns an L<Search::Elasticsearch::Client::1_0::Direct::Cluster> object which can be used
for managing the cluster, eg cluster-wide settings and cluster health.

=head2 C<nodes()>

    $node_client = $e->nodes;

Returns an L<Search::Elasticsearch::Client::1_0::Direct::Nodes> object which can be used
to retrieve node info and stats.

=head2 C<snapshot()>

    $snapshot_client = $e->snapshot;

Returns an L<Search::Elasticsearch::Client::1_0::Direct::Snapshot> object which
is used for managing backup repositories and creating and restoring
snapshots.

=head2 C<cat()>

    $cat_client = $e->cat;

Returns an L<Search::Elasticsearch::Client::1_0::Direct::Cat> object which can be used
to retrieve simple to read text info for debugging and monitoring an
Elasticsearch cluster.

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
    C<consistency>,
    C<op_type>,
    C<parent>,
    C<refresh>,
    C<replication>,
    C<routing>,
    C<timeout>,
    C<timestamp>,
    C<ttl>,
    C<version>,
    C<version_type>

See the L<index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html>
for more information.

=head2 C<create()>

    $response = $e->create(
        index   => 'index_name',        # required
        type    => 'type_name',         # required
        id      => 'doc_id',            # optional, otherwise auto-generated

        body    => { document }         # required
    );

The C<create()> method works exactly like the L</index()> method, except
that it will throw a C<Conflict> error if a document with the same
C<index>, C<type> and C<id> already exists.

Query string parameters:
    C<consistency>,
    C<op_type>,
    C<parent>,
    C<refresh>,
    C<replication>,
    C<routing>,
    C<timeout>,
    C<timestamp>,
    C<ttl>,
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
    C<_source_exclude>,
    C<_source_include>,
    C<fields>,
    C<parent>,
    C<preference>,
    C<realtime>,
    C<refresh>,
    C<routing>,
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
    C<_source_exclude>,
    C<_source_include>,
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
    C<parent>,
    C<preference>,
    C<realtime>,
    C<refresh>,
    C<routing>

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
    C<consistency>,
    C<parent>,
    C<refresh>,
    C<replication>,
    C<routing>,
    C<timeout>,
    C<version>,
    C<version_type>

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

=item * or with a script:

    $response = $e->update(
        ...,
        body => {
            script => "ctx._source.counter += incr",
            params => { incr => 5 }
        }
    );

=back

Query string parameters:
    C<consistency>,
    C<fields>,
    C<lang>,
    C<parent>,
    C<realtime>,
    C<refresh>,
    C<replication>,
    C<retry_on_conflict>,
    C<routing>,
    C<script>,
    C<script_id>,
    C<scripted_upsert>,
    C<timeout>,
    C<timestamp>,
    C<ttl>,
    C<version>,
    C<version_type>

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
    C<dfs>,
    C<field_statistics>,
    C<fields>,
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

See L<Search::Elasticsearch::Bulk> and L</bulk_helper()> for a helper module that makes
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
            { delete => { _id => 125 }},

            # update action
            { update => { _id => 126 }},
            { script => "ctx._source.counter+1" }
        ]
    );

Each action is performed separately. One failed action will not
cause the others to fail as well.

Query string parameters:
    C<consistency>,
    C<refresh>,
    C<replication>,
    C<timeout>

See the L<bulk docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html>
for more information.

=head2 C<bulk_helper()>

    $bulk_helper = $e->bulk_helper( @args );

Returns a new instance of the class specified in the L</bulk_helper_class>,
which defaults to L<Search::Elasticsearch::Bulk>.

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
    C<_source_exclude>,
    C<_source_include>,
    C<fields>,
    C<preference>,
    C<realtime>,
    C<refresh>

See the L<mget docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html>
for more information.

=head2 C<delete_by_query()>

    $result = $e->delete_by_query(
        index => 'index' | \@indices,   # required
        type  => 'type'  | \@types,     # optional

        body  => { query }              # required

    );

The C<delete_by_query()> method deletes all documents which match the
query.  For instance, to delete all documents from 2012:

    $result = $e->delete_by_query(
        body  => {
            query => {
                range => {
                    date => {
                        gte => '2012-01-01',
                        lt  => '2013-01-01'
                    }
                }
            }
        }
    );


Query string parameters:
    C<allow_no_indices>,
    C<analyzer>,
    C<consistency>,
    C<default_operator>,
    C<df>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<q>,
    C<replication>,
    C<routing>,
    C<timeout>

See the L<delete_by_query docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete-by-query.html>
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
    C<field_statistics>,
    C<fields>,
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
    C<_source_exclude>,
    C<_source_include>,
    C<allow_no_indices>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<default_operator>,
    C<df>,
    C<expand_wildcards>,
    C<explain>,
    C<fielddata_fields>,
    C<fields>,
    C<from>,
    C<ignore_unavailable>,
    C<lenient>,
    C<lowercase_expanded_terms>,
    C<preference>,
    C<q>,
    C<query_cache>,
    C<routing>,
    C<scroll>,
    C<search_type>,
    C<size>,
    C<sort>,
    C<stats>,
    C<suggest_field>,
    C<suggest_mode>,
    C<suggest_size>,
    C<suggest_text>,
    C<terminate_after>,
    C<timeout>,
    C<track_scores>,
    C<version>

See the L<search reference|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html>
for more information.

Also see L<Search::Elasticsearch::Transport/send_get_body_as>.

=head2 C<search_exists()>

The C<search_exists()> method is a quick version of search which can be
used to find out whether there are matching search results or not.
It doesn't return any results itself.

    $results = $e->search_exists(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional

        body    => { search params }        # optional
    );

Query string parameters:
    C<allow_no_indices>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<default_operator>,
    C<df>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<lenient>,
    C<lowercase_expanded_terms>,
    C<min_score>,
    C<preference>,
    C<q>,
    C<routing>

See the L<search exists reference|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-exists.html>
for more information.

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
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<lenient>,
    C<lowercase_expanded_terms>,
    C<min_score>,
    C<preference>,
    C<q>,
    C<routing>

See the L<count docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-count.html>
for more information.

=head2 C<search_template()>

    $results = $e->search_template(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional

        body    => { search params }        # optional
    );

Perform a search by specifying a template (either predefined or defined
within the C<body>) and parameters to use with the template, eg:

    $results = $e->search_template(
        template => {
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
            my_size  => 5
        }
    );

See the L<search template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html>
for more information.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<preference>,
    C<scroll>,
    C<search_type>


=head2 C<scroll()>

    $results = $e->scroll(
        scroll      => '1m',
        scroll_id   => $id
    );

When a L</search()> has been performed with the
C<scroll> parameter, the C<scroll()>
method allows you to keep pulling more results until the results
are exhausted.

B<NOTE:> you will almost always want to set the
C<search_type> to C<scan> in your
original C<search()> request.

See L</scroll_helper()> and L<Search::Elasticsearch::Scroll> for a helper utility
which makes managing scroll requests much easier.

Query string parameters:
    C<scroll>,
    C<scroll_id>

See the L<scroll docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html>
and the L<search_type docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search.html/search-request-search-type.html>
for more information.

=head2 C<clear_scroll()>

    $response = $e->clear_scroll(
        scroll_id => $id | \@ids    # required
    );

Or

    $response = $e->clear_scroll(
        body => $id
    );


The C<clear_scroll()> method can clear unfinished scroll requests, freeing
up resources on the server.

=head2 C<scroll_helper()>

    $scroll_helper = $e->scroll_helper( @args );

Returns a new instance of the class specified in the L</scroll_helper_class>,
which defaults to L<Search::Elasticsearch::Scroll>.


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
    C<search_type>

See the L<msearch docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html>
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
    C<_source_exclude>,
    C<_source_include>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<default_operator>,
    C<df>,
    C<fields>,
    C<lenient>,
    C<lowercase_expanded_terms>,
    C<parent>,
    C<preference>,
    C<q>,
    C<routing>

See the L<explain docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html>
for more information.

=head2 C<field_stats()>

    $response = $e->field_stats(
        index   => 'index'   | \@indices,   # optional
        fields  => 'field'   | \@fields,    # optional
        level   => 'cluster' | 'indices',   # optional
    );

The C<field-stats> API returns statistical properties of a field
(such as min and max values) without executing a search.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<fields>,
    C<ignore_unavailable>,
    C<level>

See the L<field-stats docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-field-stats.html>
for more information.

=head2 C<search_shards()>

    $response = $e->search_shards(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional
    )

The C<search_shards()> method returns information about which shards on
which nodes will execute a search request.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>,
    C<preference>,
    C<routing>

See the L<search-shards docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-shards.html>
for more information.

=head1 PERCOLATION METHODS

=head2 C<percolate()>

    $results = $e->percolate(
        index   => 'my_index',      # required
        type    => 'my_type',       # required

        body    => { percolation }  # required
    );

Percolation is search inverted: instead of finding docs which match a
particular query, it finds queries which match a particular document, eg
for I<alert-me-when> functionality.

The C<percolate()> method runs a percolation request to find the
queries matching a particular document. In the C<body> you should pass the
C<_source> field of the document under the C<doc> key:

    $results = $e->percolate(
        index   => 'my_index',
        type    => 'my_type',
        body    => {
            doc => {
                title => 'Elasticsearch rocks'
            }
        }
    );


Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<percolate_format>,
    C<percolate_index>,
    C<percolate_preference>,
    C<percolate_routing>,
    C<percolate_type>,
    C<preference>,
    C<routing>,
    C<version>,
    C<version_type>

See the L<percolate docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-percolate.html>
for more information.

=head2 C<count_percolate()>

    $results = $e->count_percolate(
        index   => 'my_index',      # required
        type    => 'my_type',       # required

        body    => { percolation }  # required
    );

The L</count_percolate()> request works just like the L</percolate()>
request except that it returns a count of all matching queries, instead
of the queries themselves.

    $results = $e->count_percolate(
        index   => 'my_index',
        type    => 'my_type',
        body    => {
            doc => {
                title => 'Elasticsearch rocks'
            }
        }
    );


Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<percolate_index>,
    C<percolate_type>,
    C<preference>,
    C<routing>,
    C<version>,
    C<version_type>

See the L<percolate docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-percolate.html>
for more information.

=head2 C<mpercolate()>

    $results = $e->mpercolate(
        index   => 'my_index',               # required if type
        type    => 'my_type',                # optional

        body    => [ percolation requests ]  # required
    );

Multi-percolation allows multiple L</percolate()> requests to be run
in a single request.

    $results = $e->mpercolate(
        index   => 'my_index',
        type    => 'my_type',
        body    => [
            # first request
            { percolate => {
                index => 'twitter',
                type  => 'tweet'
            }},
            { doc => {message => 'some_text' }},

            # second request
            { percolate => {
                index => 'twitter',
                type  => 'tweet',
                id    => 1
            }},
            {},
        ]
    );

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>

See the L<mpercolate docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-percolate.html>
for more information.

=head2 C<suggest()>

    $results = $e->suggest(
        index   => 'index' | \@indices,     # optional

        body    => { suggest request }      # required
    );

The C<suggest()> method is used to run
L<did-you-mean|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesteres-phrase.html>
or L<search-as-you-type|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters-completion.html>
suggestion requests, which can also be run as part of a L</search()> request.

    $results = $e->suggest(
        index   => 'my_index',
        body    => {
            my_suggestions => {
                phrase  => {
                    text    => 'johnny walker',
                    field   => 'title'
                }
            }
        }
    );


Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<preference>,
    C<routing>


=head2 C<mlt()>

    $results = $e->mlt(
        index   => 'my_index',  # required
        type    => 'my_type',   # required
        id      => 123,         # required

        body    => { search }   # optional
    );

The C<mlt()> method runs a
L<more-like-this query|http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-mlt-query.html>
to find other documents which are similar to the specified document.

Query string parameters:
    C<boost_terms>,
    C<max_doc_freq>,
    C<max_query_terms>,
    C<max_word_length>,
    C<min_doc_freq>,
    C<min_term_freq>,
    C<min_word_length>,
    C<mlt_fields>,
    C<percent_terms_to_match>,
    C<routing>,
    C<search_from>,
    C<search_indices>,
    C<search_scroll>,
    C<search_size>,
    C<search_source>,
    C<search_type>,
    C<search_types>,
    C<stop_words>

See the L<mlt docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-more-like-this.html>
for more information.

=HEAD1 INDEXED SCRIPT METHODS

If dynamic scripting is enabled, Elasticsearch allows you to store scripts in an internal index known as
C<.scripts> and reference them by id. The methods to manage indexed scripts are as follows:

=head2 C<put_script()>

    $result  = $e->put_script(
        lang => 'lang',     # required
        id   => 'id',       # required
        body => { script }  # required
    );

The C<put_script()> method is used to store a script in the C<.scripts> index. For instance:

    $result  = $e->put_scripts(
        lang => 'groovy',
        id   => 'hello_world',
        body => {
          script => q(return "hello world");
        }
    );

Query string parameters:
    C<op_type>,
    C<version>,
    C<version_type>

See the L<indexed scripts docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#_indexed_scripts> for more.

=head2 C<get_script()>

    $script = $e->get_script(
        lang => 'lang',     # required
        id   => 'id',       # required
    );

Retrieve the indexed script from the C<.scripts> index.

Query string parameters:
    C<version>,
    C<version_type>

See the L<indexed scripts docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#_indexed_scripts> for more.

=head2 C<delete_script()>

    $script = $e->delete_script(
        lang => 'lang',     # required
        id   => 'id',       # required
    );

Delete the indexed script from the C<.scripts> index.

Query string parameters:
    C<version>,
    C<version_type>

See the L<indexed scripts docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html#_indexed_scripts> for more.

=HEAD1 INDEXED SEARCH TEMPLATE METHODS

Mustache templates can be used to create search requests.  These templates can
be stored in the C<.scripts> index and retrieved by ID. The methods to
manage indexed scripts are as follows:

=head2 C<put_template()>

    $result  = $e->put_template(
        id   => 'id',                       # required
        body => { template } || "template"  # required
    );

The C<put_template()> method is used to store a template in the C<.scripts> index.
For instance:

    $result  = $e->put_template(
        id   => 'hello_world',
        body => {
          template => {
            query => {
              match => {
                title => "hello world"
              }
            }
          }
      }
    );

Query string parameters: None

See the L<indexed search template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html#_pre_registered_template> for more.

=head2 C<get_template()>

    $script = $e->get_template(
        id   => 'id',       # required
    );

Retrieve the indexed template from the C<.scripts> index.

Query string parameters:
    C<version>,
    C<version_type>

See the L<indexed search template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html#_pre_registered_template> for more.

=head2 C<delete_template()>

    $script = $e->delete_template(
        id   => 'id',       # required
    );

Delete the indexed template from the C<.scripts> index.

Query string parameters: None

See the L<indexed search template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html#_pre_registered_template> for more.

