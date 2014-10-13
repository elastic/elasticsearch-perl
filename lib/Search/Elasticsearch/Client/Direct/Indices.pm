package Search::Elasticsearch::Client::Direct::Indices;

use Moo;
with 'Search::Elasticsearch::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('indices');

1;

__END__

# ABSTRACT: A client for running index-level requests

=head1 DESCRIPTION

This module provides methods to make index-level requests, such as
creating and deleting indices, managing type mappings, index settings,
warmers, index templates and aliases.

It does L<Search::Elasticsearch::Role::Client::Direct>.

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

The C<create()> method is used to create an index. Optionally, index
settings, type mappings and index warmers can be added at the same time.

Query string parameters:
    C<master_timeout>,
    C<timeout>

See the L<create index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-create-index.html>
for more information.

=head2 C<get()>

    $response = $e->indices->get(
        index   => 'index'   | \@indices    # optional
        feature => 'feature' | \@features   # optional
    );

Returns the aliases, settings, mappings, and warmers for the specified indices.
The C<feature> parameter can be set to none or more of: C<_settings>, C<_mappings>,
C<_warmers> and C<_aliases>.

See the L<get index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-get-index.html>.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>

=head2 C<exists()>

    $bool = $e->indices->exists(
        index => 'index' | \@indices    # required
    );

The C<exists()> method returns C<1> or the empty string to indicate
whether the specified index or indices exist.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>

See the L<index exists docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-indices-exists.html>
for more information.

=head2 C<delete()>

    $response = $e->indices->delete(
        index => 'index' | \@indices    # required
    );

The C<delete()> method deletes the specified indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<master_timeout>,
    C<timeout>

See the L<delete index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-delete-index.html>
for more information.

=head2 C<close()>

    $response = $e->indices->close(
        index => 'index' | \@indices    # required
    );

The C<close()> method closes the specified indices, reducing resource usage
but allowing them to be reopened later.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>
    C<master_timeout>,
    C<timeout>

See the L<close index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-open-close.html>
for more information.

=head2 C<open()>

    $response = $e->indices->open(
        index => 'index' | \@indices    # required
    );

The C<open()> method opens closed indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>
    C<master_timeout>,
    C<timeout>

See the L<open index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-open-close.html>
for more information.

=head2 C<clear_cache()>

    $response = $e->indices->clear_cache(
        index => 'index' | \@indices        # optional
    );

The C<clear_cache()> method is used to clear the in-memory filter, fielddata,
or id cache for the specified indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<fielddata>,
    C<fields>,
    C<filter>,
    C<filter_cache>,
    C<filter_keys>,
    C<id>,
    C<id_cache>,
    C<ignore_unavailable>,
    C<query_cache>,
    C<recycler>

See the L<clear_cache docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-clearcache.html>
for more information.

=head2 C<refresh()>

    $response = $e->indices->refresh(
        index => 'index' | \@indices    # optional
    );

The C<refresh()> method refreshes the specified indices (or all indices),
allowing recent changes to become visible to search. This process normally
happens automatically once every second by default.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<force>,
    C<ignore_unavailable>

See the L<refresh index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-refresh.html>
for more information.

=head2 C<flush()>

    $response = $e->indices->flush(
        index => 'index' | \@indices    # optional
    );

The C<flush()> method causes the specified indices (or all indices) to be
written to disk with an C<fsync>, and clears out the transaction log.
This process normally happens automatically.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<force>,
    C<full>,
    C<ignore_unavailable>,
    C<wait_if_ongoing>

See the L<flush index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-flush.html>
for more information.

=head2 C<optimize()>

    $response = $e->indices->optimize(
        index => 'index' | \@indices    # optional
    );

The C<optimize()> method rewrites all the data in an index into at most
C<max_num_segments>.  This is a very heavy operation and should only be run
with care, and only on indices that are no longer being updated.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<flush>,
    C<ignore_unavailable>,
    C<max_num_segments>,
    C<only_expunge_deletes>,
    C<wait_for_merge>

See the L<optimize index docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-optimize.html>
for more information.

=head2 C<get_upgrade()>

    $response = $e->indices->get_upgrade(
        index => 'index' | \@indices    # optional
    );

The C<get_upgrade()> method returns information about which indices need to be
upgraded, which can be done with the C<upgrade()> method.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>

See the L<upgrade docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-upgrade.html>
for more information.

=head2 C<upgrade()>

    $response = $e->indices->upgrade(
        index => 'index' | \@indices    # optional
    );

The C<upgrade()> method upgrades all segments in the specified indices to the latest format.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<wait_for_completion>

See the L<upgrade docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-upgrade.html>
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
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<ignore_conflicts>,
    C<master_timeout>,
    C<timeout>

See the L<put_mapping docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-put-mapping.html>
for more information.


=head2 C<get_mapping()>

    $result = $e->indices->get_mapping(
        index => 'index' | \@indices    # optional,
        type  => 'type'  | \@types      # optional
    );

The C<get_mapping()> method returns the type definitions for one, more or
all types in one, more or all indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>

See the L<get_mapping docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-get-mapping.html>
for more information.

=head2 C<get_field_mapping()>

    $result = $e->indices->get_field_mapping(
        index => 'index' | \@indices    # optional,
        type  => 'type'  | \@types      # optional,
        field => 'field' | \@fields     # required

        include_defaults => 0 | 1
    );

The C<get_field_mapping()> method returns the field definitions for one, more or
all fields in one, more or all types and indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<include_defaults>,
    C<local>

See the L<get_mapping docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-get-field-mapping.html>
for more information.

=head2 C<exists_type()>

    $bool = $e->indices->exists_type(
        index => 'index' | \@indices    # required,
        type  => 'type'  | \@types      # required
    );

The C<exists_type()> method checks for the existence of all specified types
in all specified indices, and returns C<1> or the empty string.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>

See the L<exists_type docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-types-exists.html>
for more information.

=head2 C<delete_mapping()>

    $response = $e->indices->delete_mapping(
        index => 'index' | \@indices    # required,
        type  => 'type'  | \@types      # required
    );

The C<delete_mapping()> method deletes the type mappings (and all documents of
that type) in all specified indices.

Query string parameters:
    C<master_timeout>

See the L<delete_mapping docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-delete-mapping.html>
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
    C<master_timeout>,
    C<timeout>

See the L<update_aliases docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<get_aliases()>

    $result = $e->indices->get_aliases(
        index   => 'index' | \@indices      # optional
        alias   => 'alias' | \@aliases      # optional
    );

The C<get_aliases()> method returns a list of aliases per index for all
the specified indices.

Query string parameters:
    C<local>,
    C<timeout>

See the L<get_aliases docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<put_alias()>

    $response = $e->indices->put_alias(
        index => 'index' | \@indices        # optional,
        name  => 'alias',                   # required

        body  => { alias defn }             # optional
    );

The C<put_alias()> method creates an index alias. For instance:

    $response = $e->indices->put_alias(
        index => 'my_index',
        name  => 'twitter',
        body => {
            filter => { term => { user_id => 'twitter' }}
        }
    );

Query string parameters:
    C<master_timeout>,
    C<timeout>

See the L<put_alias docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<get_alias()>

    $result = $e->indices->get_alias(
        index   => 'index' | \@indices,     # optional
        name    => 'alias' | \@aliases      # optional
    );

The C<get_alias()> method returns the alias definitions for the specified
aliases in the specified indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>

See the L<get_alias docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<exists_alias()>

    $bool = $e->indices->exists_alias(
        index   => 'index' | \@indices,     # optional
        name    => 'alias' | \@aliases      # optional
    );

The C<exists_alias()> method returns C<1> or the empty string depending on
whether the specified aliases exist in the specified indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>

See the L<exists_alias docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<delete_alias()>

    $response = $e->indices->delete_alias(
        index   => 'index' | \@indices        # required,
        name    => 'alias' | \@aliases        # required
    );

The C<delete_alias()> method deletes one or more aliases from one or more
indices.

Query string parameters:
    C<master_timeout>,
    C<timeout>

See the L<delete_alias docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head1 SETTINGS METHODS

=head2 C<put_settings()>

    $response = $e->indices->put_settings(
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
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<flat_settings>,
    C<ignore_unavailable>,
    C<master_timeout>

See the L<put_settings docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-update-settings.html>
for more information.

=head2 C<get_settings()>

    $result = $e->indices->get_settings(
        index   => 'index' | \@indices      # optional
        name    => 'name'  | \@names        # optional
    );

The C<get_settings()> method retrieves the index settings for the specified
indices or all indices.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<flat_settings>,
    C<ignore_unavailable>,
    C<local>

See the L<get_settings docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-get-settings.html>
for more information.

=head1 TEMPLATE METHODS

=head2 C<put_template()>

    $response = $e->indices->put_template(
        name => 'template'                  # required
        body => { template defn }           # required
    );

The C<put_template()> method is used to create or update index templates.

Query string parameters:
    C<create>,
    C<flat_settings>,
    C<master_timeout>,
    C<order>,
    C<timeout>

See the L<put_template docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-templates.html>
for more information.

=head2 C<get_template()>

    $result = $e->indices->get_template(
        name  => 'template'                 # optional
    );

The C<get_template()> method is used to retrieve a named template.

Query string parameters:
    C<flat_settings>,
    C<local>

See the L<get_template docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-templates.html>
for more information.

=head2 C<exists_template()>

    $result = $e->indices->exists_template(
        name  => 'template'                 # required
    );

The C<exists_template()> method is used to check whether the named template exists.

Query string parameters:
    C<local>

See the L<get_template docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-templates.html>
for more information.

=head2 C<delete_template()>

    $response = $e->indices->delete_template(
        name  => 'template'                 # required
    );

The C<delete_template()> method is used to delete a named template.

Query string parameters:
    C<master_timeout>,
    C<timeout>

See the L<delete_template docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-templates.html>
for more information.


=head1 WARMER METHODS

=head2 C<put_warmer()>

    $response = $e->indices->put_warmer(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional
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
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<master_timeout>

See the L<put_warmer docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-warmers.html>
for more information.

=head2 C<get_warmer()>

    $response = $e->indices->get_warmer(
        index   => 'index'  | \@indices,    # optional
        type    => 'type'   | \@types,      # optional
        name    => 'warmer' | \@warmers,    # optional
    );

The C<get_warmer()> method is used to retrieve warmers by name.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<local>

See the L<get_warmer docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-warmers.html>
for more information.

=head2 C<delete_warmer()>

    $response = $e->indices->get_warmer(
        index   => 'index'  | \@indices,    # required
        name    => 'warmer' | \@warmers,    # required
    );

The C<delete_warmer()> method is used to delete warmers by name.

Query string parameters:
    C<master_timeout>

See the L<delete_warmer docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-warmers.html>
for more information.

=head1 STATS METHODS

=head2 C<stats()>

    $result = $e->indices->stats(
        index   => 'index'  | \@indices      # optional
        metric  => 'metric' | \@metrics      # optional
    );

The C<stats()> method returns statistical information about one, more or all
indices. By default it returns all metrics, but you can limit which metrics
are returned by specifying the C<metric>.

Allowed metrics are:
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

See the L<stats docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-stats.html>
for more information.

=head2 C<recovery()>

    $result = $e->indices->recovery(
        index   => 'index' | \@indices      # optional
    );

Provides insight into on-going shard recoveries.

Query string parameters:
    C<active_only>,
    C<detailed>,
    C<human>

See the L<recovery docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-recovery.html>
for more information.

=head2 C<segments()>

    $result = $e->indices->segments(
        index   => 'index' | \@indices      # optional
    );

The C<segments()> method is used to return information about the segments
that an index contains.

Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>

See the L<segments docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-segments.html>
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
    C<analyzer>,
    C<char_filters>,
    C<field>,
    C<filters>,
    C<format>,
    C<prefer_local>,
    C<text>,
    C<tokenizer>

See the L<analyze docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-analyze.html>
for more information.

=head2 C<validate_query()>

    $result = $e->indices->validate_query(
        index   => 'index' | \@indices,     # optional
        type    => 'type'  | \@types,       # optional

        body    => { query }
    );

The C<validate_query()> method accepts a query in the C<body> and checks
whether the query is valid or not.  Most useful when C<explain> is set
to C<true>, in which case it includes an execution plan in the output.


Query string parameters:
    C<allow_no_indices>,
    C<expand_wildcards>,
    C<explain>,
    C<ignore_unavailable>,
    C<q>,
    C<source>

See the L<validate_query docs|http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-validate.html>
for more information.



