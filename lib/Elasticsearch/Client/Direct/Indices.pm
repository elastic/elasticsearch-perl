#===================================
package Elasticsearch::Client::Direct::Indices;
#===================================
use Moo;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('indices');

1;

__END__

# ABSTRACT: A client for running index-level requests

=head1 DESCRIPTION

This module provides methods to make index-level requests, such as
creating and deleting indices, managing type mappings, index settings,
warmers, index templates and aliases.

It does L<Elasticsearch::Role::Client::Direct>.

=head1 INDEX METHODS

=head2 C<create()>

    $result = $e->indices->create(
        index => 'my_index'             # required

        body  => {                      # optional
            index settings
            mappings
            warmers
        }
    );

The C<create()> method is used to creat an index. Optionally, index
settings, type mappings and index warmers can be added at the same time.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<create index docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-create-index/>
for more information.

=head2 C<exists()>

    $bool = $e->indices->exists(
        index => 'index' | \@indices    # required
    );

The C<exists()> method returns C<1> or the empty string to indicate
whether the specified index or indices exist.

See the L<index exists docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-indices-exists/>
for more information.

=head2 C<delete()>

    $response = $e->indices->delete(
        index => 'index' | \@indices    # required
    );

The C<delete()> method deletes the specified indices.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<delete index docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-delete-index/>
for more information.

=head2 C<close()>

    $response = $e->indices->close(
        index => 'index' | \@indices    # required
    );

The C<close()> method closes the specified indices, reducing resource usage
but allowing them to be reopened later.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<close index docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-open-close/>
for more information.

=head2 C<open()>

    $response = $e->indices->open(
        index => 'index' | \@indices    # optional
    );

The C<open()> method opens closed indices.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<open index docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-open-close/>
for more information.

=head2 C<clear_cache()>

    $response = $e->indices->clear_cache(
        index => 'index' | \@indices        # optional
    );

The C<clear_cache()> method is used to clear the in-memory filter, fielddata,
or id cache for the specified indices.

Query string parameters:
    L<fielddata|Elasticsearch::Util::API::QS/fielddata>,
    L<fields|Elasticsearch::Util::API::QS/fields>,
    L<filter|Elasticsearch::Util::API::QS/filter>,
    L<filter_cache|Elasticsearch::Util::API::QS/filter_cache>,
    L<filter_keys|Elasticsearch::Util::API::QS/filter_keys>,
    L<id|Elasticsearch::Util::API::QS/id>,
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>,
    L<index|Elasticsearch::Util::API::QS/index>,
    L<recycler|Elasticsearch::Util::API::QS/recycler>

See the L<clear_cache docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-clearcache/>
for more information.

=head2 C<refresh()>

    $response = $e->indices->refresh(
        index => 'index' | \@indices    # optional
    );

The C<refresh()> method refreshes the specified indices (or all indices),
allowing recent changes to become visible to search. This process normally
happens automatically once every second by default.

Query string parameters:
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>

See the L<refresh index docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-refresh/>
for more information.

=head2 C<flush()>

    $response = $e->indices->flush(
        index => 'index' | \@indices    # optional
    );

The C<flush()> method causes the specified indices (or all indices) to be
written to disk with an C<fsync>, and clears out the transaction log.
This process normally happens automatically.

Query string parameters:
    L<force|Elasticsearch::Util::API::QS/force>,
    L<full|Elasticsearch::Util::API::QS/full>,
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>,
    L<refresh|Elasticsearch::Util::API::QS/refresh>

See the L<flush index docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-flush/>
for more information.

=head2 C<optimize()>

    $response = $e->indices->optimize(
        index => 'index' | \@indices    # optional
    );

The C<optimize()> method rewrites all the data in an index into at most
C<max_num_segments>.  This is a very heavy operation and should only be run
with care, and only on indices that are no longer being updated.

Query string parameters:
    L<flush|Elasticsearch::Util::API::QS/flush>,
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>,
    L<max_num_segments|Elasticsearch::Util::API::QS/max_num_segments>,
    L<only_expunge_deletes|Elasticsearch::Util::API::QS/only_expunge_deletes>,
    L<refresh|Elasticsearch::Util::API::QS/refresh>,
    L<wait_for_merge|Elasticsearch::Util::API::QS/wait_for_merge>

See the L<optimize index docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-optimize/>
for more information.

=head2 C<snapshot_index()>

    $response = $e->indices->snapshot_index(
        index => 'index' | \@indices    # optional
    );

Deprecated.

See the L<snapshot_index docs|http://www.elasticsearch.org/guide/reference/>
for more information.

=head1 MAPPING METHODS

=head2 C<put_mapping()>

    $response = $e->indices->put_mapping(
        index => 'index' | \@indices    # optional,
        type  => 'type',                # required

        body  => { mapping }            # required
    )

The C<put_mapping()> method is used to create or update a type
mapping on an existing index.  Mapping updates are allowed to add new
fields, but not to overwrite or change existing fields.

For instance:

    $response = $e->indices->put_mapping(
        index   => 'users',
        type    => 'user',
        body    => {
            user => {
                properties => {
                    name => { type => 'string'  },
                    age  => { type => 'integer' }
                }
            }
        }
    );

Query string parameters:
    L<ignore_conflicts|Elasticsearch::Util::API::QS/ignore_conflicts>,
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<put_mapping docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-put-mapping/>
for more information.


=head2 C<get_mapping()>

    $result = $e->indices->get_mapping(
        index => 'index' | \@indices    # optional,
        type  => 'type'  | \@types      # optional
    );

The C<get_mapping()> method returns the type definitions for one, more or
all types in one, more or all indices.

See the L<get_mapping docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-get-mapping/>
for more information.

=head2 C<exists_type()>

    $bool = $e->indices->exists_type(
        index => 'index' | \@indices    # optional,
        type  => 'type'  | \@types      # required
    );

The C<exists_type()> method checks for the existence of all specified types
in all specified indices, and returns C<1> or the empty string.

Query string parameters:
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>

See the L<exists_type docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-types-exists/>
for more information.

=head2 C<delete_mapping()>

    $response = $e->indices->delete(
        index => 'index' | \@indices    # required,
        type  => 'type'                 # required
    );

The C<delete_mapping()> method deletes the type mappings (and all documents of
that type) in all specified indices.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>

See the L<delete_mapping docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-delete-mapping/>
for more information.

=head1 ALIAS METHODS

=head2 C<update_aliases()>

    $response = $e->indices->update_aliases(
        body => { actions }             # required
    );

The C<update_aliases()> method changes (by adding or removing) multiple
index aliases atomically. For instance:

    $response = $e->indices->update_aliases(
        body => {
            actions => [
                { add    => { alias => 'current', index => 'logs_2013_09' }},
                { remove => { alias => 'current', index => 'logs_2013_08' }}
            ]
        }
    );

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<update_aliases docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/>
for more information.

=head2 C<get_aliases()>

    $result = $e->indices->get_aliases(
        index   => 'index' | \@indices      # optional
    );

The C<get_aliases()> method returns a list of aliases per index for all
the specified indices.

Query string parameters:
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<get_aliases docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/>
for more information.

=head2 C<put_alias()>

    $response = $e->indices->put_alias(
        index => 'index',                   # required
        name  => 'alias',                   # required

        body  => { alias defn }             # optional
    );

The C<put_alias()> method creates a single index alias. For instance:

    $response = $e->indices->put_alias(
        index => 'my_index',
        name  => 'twitter',
        body => {
            filter => { term => { user_id => 'twitter' }}
        }
    );

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<put_alias docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/>
for more information.

=head2 C<get_alias()>

    $result = $e->indices->get_alias(
        index   => 'index' | \@indices,     # optional
        name    => 'alias' | \@aliases      # required
    );

The C<get_alias()> method returns the aliase defintions for the specified
aliases in the specified indices.

Query string parameters:
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>

See the L<get_alias docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/>
for more information.

=head2 C<exists_alias()>

    $bool = $e->indices->exists_alias(
        index   => 'index' | \@indices,     # optional
        name    => 'alias' | \@aliases      # required
    );

The C<exists_alias()> method returns C<1> or the empty string depending on
whether the specified aliases exist in the specified indices.

Query string parameters:
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>

See the L<exists_alias docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/>
for more information.

=head2 C<delete_alias()>

    $response = $e->indices->delete_alias(
        index   => 'index',                 # required
        name    => 'alias'                  # required
    );

The C<delete_alias()> method deletes a single alias in a a single index.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<delete_alias docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-aliases/>
for more information.

=head1 SETTINGS METHODS

=head2 C<put_settings()>

    $response = $e->indices->get_settings(
        index   => 'index' | \@indices      # optional

        body    => { settings }
    );

The C<put_settings()> method sets the index settings for the specified
indices or all indices. For instance:

    $response = $e->indices->put_settings(
        body => {
            "index.refresh_interval" => -1
        }
    );

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>

See the L<put_settings docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-update-settings/>
for more information.

=head2 C<get_settings()>

    $result = $e->indices->get_settings(
        index   => 'index' | \@indices      # optional
    );

The C<get_settings()> method retrieves the index settings for the specified
indices or all indices.

See the L<get_settings docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-get-settings/>
for more information.

=head1 TEMPLATE METHODS

=head2 C<put_template()>

    $response = $e->indices->put_template(
        name => 'template'                  # required
        body => { template defn }           # required
    );

The C<put_template()> method is used to create or update index templates.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<order|Elasticsearch::Util::API::QS/order>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<put_template docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-templates/>
for more information.

=head2 C<get_template()>

    $result = $e->indices->get_template(
        name  => 'template'                 # required
    );

The C<get_template()> method is used to retrieve a named template.

See the L<get_template docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-templates/>
for more information.


=head2 C<delete_template()>

    $response = $e->indices->delete_template(
        name  => 'template'                 # required
    );

The C<delete_template()> method is used to delete a named template.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>,
    L<timeout|Elasticsearch::Util::API::QS/timeout>

See the L<delete_template docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-templates/>
for more information.


=head1 WARMER METHODS

=head2 C<put_warmer()>

    $response = $e->indices->put_warmer(
        index   => 'index' | \@indices,     # optional
        name    => 'warmer',                # required

        body    => { warmer defn }          # required
    );

The C<put_warmer()> method is used to create or update named warmers which
are used to I<warm up> new segments in the index before they are exposed
to user searches.  For instance:

    $response = $e->indices->put_warmer(
        index   => 'my_index',
        name    => 'date_field_warmer',
        body    => {
            sort => 'date'
        }
    );

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>

See the L<put_warmer docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-warmers/>
for more information.

=head2 C<get_warmer()>

    $response = $e->indices->get_warmer(
        index   => 'index'  | \@indices,    # optional
        name    => 'warmer' | \@warmers,    # optional
    );

The C<get_warmer()> method is used to retrieve warmers by name.

See the L<get_warmer docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-warmers/>
for more information.

=head2 C<delete_warmer()>

    $response = $e->indices->get_warmer(
        index   => 'index'  | \@indices,    # required
        name    => 'warmer' | \@warmers,    # optional
    );

The C<delete_warmer()> method is used to delete warmers by name.

Query string parameters:
    L<master_timeout|Elasticsearch::Util::API::QS/master_timeout>

See the L<delete_warmer docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-warmers/>
for more information.

=head1 STATS METHODS

=head2 C<stats()>

    $result = $e->indices->stats(
        index   => 'index' | \@indices      # optional
    );

The C<stats()> method returns statistical information about one, more or all
indices.  Use the query string parameters to specify what information you
want returned.

Query string parameters:
    L<all|Elasticsearch::Util::API::QS/all>,
    L<clear|Elasticsearch::Util::API::QS/clear>,
    L<completion|Elasticsearch::Util::API::QS/completion>,
    L<completion_fields|Elasticsearch::Util::API::QS/completion_fields>,
    L<docs|Elasticsearch::Util::API::QS/docs>,
    L<fielddata|Elasticsearch::Util::API::QS/fielddata>,
    L<fielddata_fields|Elasticsearch::Util::API::QS/fielddata_fields>,
    L<fields|Elasticsearch::Util::API::QS/fields>,
    L<filter_cache|Elasticsearch::Util::API::QS/filter_cache>,
    L<flush|Elasticsearch::Util::API::QS/flush>,
    L<get|Elasticsearch::Util::API::QS/get>,
    L<groups|Elasticsearch::Util::API::QS/groups>,
    L<id_cache|Elasticsearch::Util::API::QS/id_cache>,
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>,
    L<indexing|Elasticsearch::Util::API::QS/indexing>,
    L<merge|Elasticsearch::Util::API::QS/merge>,
    L<refresh|Elasticsearch::Util::API::QS/refresh>,
    L<search|Elasticsearch::Util::API::QS/search>,
    L<store|Elasticsearch::Util::API::QS/store>,
    L<warmer|Elasticsearch::Util::API::QS/warmer>

See the L<stats docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-stats/>
for more information.

=head2 C<status()>

    $result = $e->indices->status(
        index   => 'index' | \@indices      # optional
    );

Deprecated.

Query string parameters:
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>,
    L<recovery|Elasticsearch::Util::API::QS/recovery>,
    L<snapshot|Elasticsearch::Util::API::QS/snapshot>

See the L<status docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-status/>
for more information.

=head2 C<segments()>

    $result = $e->indices->segments(
        index   => 'index' | \@indices      # optional
    );

The C<segments()> method is used to return information about the segments
that an index contains.

Query string parameters:
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>

See the L<segments docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-segments/>
for more information.

=head1 QUERY AND ANALYSIS METHODS

=head2 C<analyze()>

    $result = $e->indices->analyze(
        index   => 'index'                  # optional,
        body    => 'text to analyze'
    );

The C<analyze()> method passes the text in the C<body> through the specified
C<analyzer>, C<tokenizer> or token C<filter> - which may be global, or associated
with a particular index or field - and returns the tokens.  Very useful
for debugging analyzer configurations.

Query string parameters:
    L<analyzer|Elasticsearch::Util::API::QS/analyzer>,
    L<field|Elasticsearch::Util::API::QS/field>,
    L<filters|Elasticsearch::Util::API::QS/filters>,
    L<format|Elasticsearch::Util::API::QS/format>,
    L<index|Elasticsearch::Util::API::QS/index>,
    L<prefer_local|Elasticsearch::Util::API::QS/prefer_local>,
    L<text|Elasticsearch::Util::API::QS/text>,
    L<tokenizer|Elasticsearch::Util::API::QS/tokenizer>

See the L<analyze docs|http://www.elasticsearch.org/guide/reference/api/admin-indices-analyze/>
for more information.

=head2 C<validate_query()>

    $result = $e->indices->validate_query(
        index   => 'index' | \@indices,     # optional
        body    => { query }
    );

The C<validate_query()> method accepts a query in the C<body> and checks
whether the query is valid or not.  Most useful when C<explain> is set
to C<true>, in which case it includes an execution plan in the output.


Query string parameters:
    L<explain|Elasticsearch::Util::API::QS/explain>,
    L<ignore_indices|Elasticsearch::Util::API::QS/ignore_indices>,
    L<q|Elasticsearch::Util::API::QS/q>,
    L<source|Elasticsearch::Util::API::QS/source>

See the L<validate_query docs|http://www.elasticsearch.org/guide/reference/api/validate/>
for more information.



