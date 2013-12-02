package Elasticsearch::Client::Direct;

use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';

use Elasticsearch::Util qw(parse_params);
use namespace::clean;

has 'cluster' => ( is => 'lazy' );
has 'indices' => ( is => 'lazy' );

__PACKAGE__->_install_api('');

#===================================
sub create {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $params->{op_type} = 'create';
    $self->_index( 'create', $params );
}

#===================================
sub index {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $self->_index( 'index', $params );
}

#===================================
sub _index {
#===================================
    my ( $self, $name, $params ) = @_;
    my $defn = $self->api->{index};
    unless ( defined $params->{id} and length $params->{id} ) {
        $defn = { %$defn, method => 'POST' };
    }
    $self->perform_request( { %$defn, name => $name }, $params );
}

#===================================
sub _build_cluster {
#===================================
    my ( $self, $name ) = @_;
    require Elasticsearch::Client::Direct::Cluster;
    Elasticsearch::Client::Direct::Cluster->new(
        {   transport => $self->transport,
            logger    => $self->logger
        }
    );
}

#===================================
sub _build_indices {
#===================================
    my ( $self, $name ) = @_;
    require Elasticsearch::Client::Direct::Indices;
    Elasticsearch::Client::Direct::Indices->new(
        {   transport => $self->transport,
            logger    => $self->logger
        }
    );
}

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch APIs

=head1 SYNOPSIS

Create a client:

    use Elasticsearch;
    my $e = Elasticsearch->new(
        client => 'Direct'          # default
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

    $state = $e->cluster->state;
    $stats = $e->cluster->node_stats;

=head1 DESCRIPTION

The L<Elasticsearch::Client::Direct> class provides the default
client that is returned by:

    $e = Elasticsearch->new;

It is intended to be as close as possible to the native REST API that
Elasticsearch uses, so that it is easy to translate the
L<Elasticsearch reference documentation|http://www.elasticsearch/guide>
for an API to the equivalent in this client.

This class provides the methods for L<document CRUD|/DOCUMENT CRUD METHODS>,
L<bulk document CRUD|/BULK DOCUMENT CRUD METHODS> and L<search|/SEARCH METHODS>.
It also provides access to clients for managing L<indices|/indices()>
and the L<cluster|/cluster()>.

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

    $e->analyze( body => "The quick brown fox");

=head2 Ignore parameter

Normally, any HTTP status code outside the 200-299 range will result in
an error being thrown.  To suppress these errors, you can specify which
status codes to ignore in the C<ignore> parameter.

    $e->indices->delete(
        index  => 'my_index',
        ignore => 404
    );

This is most useful for
L<Missing|Elasticsearch::Error/Elasticsearch::Error::Missing> errors, which
are triggered by a C<404> status code when some requested resource does
not exist.

Multiple error codes can be specified with an array:

    $e->indices->delete(
        index  => 'my_index',
        ignore => [404,409]
    );

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

Returns an L<Elasticsearch::Client::Direct::Indices> object which can be used
for managing indices, eg creating, deleting indices, managing mapping,
index settings etc.

=head2 C<cluster()>

    $cluster_client = $e->cluster;

Returns an L<Elasticsearch::Client::Direct::Cluster> object which can be used
for managing the cluster, eg cluster-wide settings, cluster health,
node information and stats.

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
    C<percolate>,
    C<refresh>,
    C<replication>,
    C<routing>,
    C<timeout>,
    C<timestamp>,
    C<ttl>,
    C<version>,
    C<version_type>

See the L<index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-index_.html>
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
    C<percolate>,
    C<refresh>,
    C<replication>,
    C<routing>,
    C<timeout>,
    C<timestamp>,
    C<ttl>,
    C<version>,
    C<version_type>

See the L<create docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-create.html>
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
    C<routing>

See the L<get docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-get.html>
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
    C<_source_exclude>,
    C<_source_include>,
    C<parent>,
    C<preference>,
    C<realtime>,
    C<refresh>,
    C<routing>

See the L<get_source docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-get.html>
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

See the L<exists docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-get.html>
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

See the L<delete docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-delete.html>
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
    C<percolate>,
    C<realtime>,
    C<refresh>,
    C<replication>,
    C<retry_on_conflict>,
    C<routing>,
    C<script>,
    C<timeout>,
    C<timestamp>,
    C<ttl>,
    C<version>,
    C<version_type>

See the L<update docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-update.html>
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

See L<Elasticsearch::Bulk> for a helper module that makes
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
    C<timeout>,
    C<type>

See the L<bulk docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-bulk.html>
for more information.

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

See the L<mget docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-multi-get.html>
for more information.

=head2 C<delete_by_query()>

    $result = $e->delete_by_query(
        index => 'index' | \@indices,   # optional
        type  => 'type'  | \@types,     # optional

        body  => { query }              # required

    );

The C<delete_by_query()> method deletes all documents which match the
query.  For instance, to delete all documents from 2012:

    $result = $e->delete_by_query(
        body  => {
            range => {
                date => {
                    gte => '2012-01-01',
                    lt  => '2013-01-01'
                }
            }
        }
    );

Query string parameters:
    C<analyzer>,
    C<consistency>,
    C<default_operator>,
    C<df>,
    C<ignore_indices>,
    C<q>,
    C<replication>,
    C<routing>,
    C<source>,
    C<timeout>

See the L<delete_by_query docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-delete-by-query.html>
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
L<facets|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-facets.thml>
(aggregations on particular fields),
L<highlighted snippets|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-highlighting.html>
and L<did-you-mean|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-suggesters-phrase.html>
or L<search-as-you-type|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-suggesters-completion.html>
suggestions.

The I<lite> L<version of search|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-uri-request.html>
allows you to specify a query string in the C<q> parameter, using the
Lucene query string syntax:

    $results = $e->search( q => 'title:(elasticsearch clients)');

However, the preferred way to search is by using the
L<Query DSL|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl.html>
to create a query, and passing that C<query> in the
L<request body|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-body.html>:

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
    C<analyze_wildcard>,
    C<analyzer>,
    C<default_operator>,
    C<df>,
    C<explain>,
    C<fields>,
    C<from>,
    C<ignore_indices>,
    C<indices_boost>,
    C<lenient>,
    C<lowercase_expanded_terms>,
    C<preference>,
    C<q>,
    C<routing>,
    C<scroll>,
    C<search_type>,
    C<size>,
    C<sort>,
    C<source>,
    C<stats>,
    C<suggest_field>,
    C<suggest_mode>,
    C<suggest_size>,
    C<suggest_text>,
    C<timeout>,
    C<version>

See the L<search reference|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-body.html>
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
        body => { match => { title => 'Elasticsearch clients' }}
    );

Query string parameters:
    C<ignore_indices>,
    C<min_score>,
    C<preference>,
    C<routing>,
    C<source>

See the L<count docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-count.html>
for more information.

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

See L<Elasticsearch::Scroll> for a helper utility which makes
managing scroll requests much easier.

Query string parameters:
    C<scroll>,
    C<scroll_id>

See the L<scroll docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-scroll.html>
and the L<search_type docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search.html/search-request-search-type.html>
for more information.

=head2 C<clear_scroll()>

    $response = $e->clear_scroll(
        scroll_id => $id | \@ids    # required
    );

The C<clear_scroll()> method can clear unfinished scroll requests, freeing
up resources on the server.

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

See the L<msearch docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-multi-search.html>
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
    C<routing>,
    C<source>

See the L<explain docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-explain.html>
for more information.

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
    C<prefer_local>

See the L<percolate docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-percolate.html>
for more information.

=head2 C<suggest()>

    $results = $e->suggest(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional

        body    => { suggest request }      # required
    );

The C<suggest()> method is used to run
L<did-you-mean|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-suggesteres-phrase.html>
or L<search-as-you-type|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-suggesters-completion.html>
suggestion requests, which can also be run as part of a L</search()> request.

    $results = $e->suggest(
        index   => 'my_index',
        type    => 'my_type',
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
    C<ignore_indices>,
    C<preference>,
    C<routing>,
    C<source>


=head2 C<mlt()>

    $results = $e->mlt(
        index   => 'my_index',  # required
        type    => 'my_type',   # required
        id      => 123,         # required

        body    => { search }   # optional
    );

The C<mlt()> method runs a
L<more-like-this query|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-mlt-query.html>
to find other documents which are similar to the specified document.

Query string parameters:
    C<boost_terms>,
    C<max_doc_freq>,
    C<max_query_terms>,
    C<max_word_len>,
    C<min_doc_freq>,
    C<min_term_freq>,
    C<min_word_len>,
    C<mlt_fields>,
    C<percent_terms_to_match>,
    C<routing>,
    C<search_from>,
    C<search_indices>,
    C<search_query_hint>,
    C<search_scroll>,
    C<search_size>,
    C<search_source>,
    C<search_type>,
    C<search_types>,
    C<stop_words>

See the L<mlt docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-more-like-this.html>
for more information.


