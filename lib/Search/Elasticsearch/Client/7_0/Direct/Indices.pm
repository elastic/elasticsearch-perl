# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

package Search::Elasticsearch::Client::7_0::Direct::Indices;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('indices');

1;

__END__

# ABSTRACT: A client for running index-level requests

=head1 DESCRIPTION

This module provides methods to make index-level requests, such as
creating and deleting indices, managing type mappings, index settings,
index templates and aliases.

It does L<Search::Elasticsearch::Role::Client::Direct>.

=head1 INDEX METHODS

=head2 C<create()>

    $result = $e->indices->create(
        index => 'my_index'             # required

        body  => {                      # optional
            index settings
            mappings
            aliases
        }
    );

The C<create()> method is used to create an index. Optionally, index
settings, type mappings, and aliases can be added at the same time.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<include_type_name>,
    C<master_timeout>,
    C<timeout>,
    C<update_all_types>,
    C<wait_for_active_shards>

See the L<create index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html>
for more information.

=head2 C<get()>

    $response = $e->indices->get(
        index   => 'index'   | \@indices    # required
    );

Returns the aliases, settings, and mappings for the specified indices.

See the L<get index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-index.html>.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<flat_settings>,
    C<human>,
    C<ignore_unavailable>,
    C<include_defaults>,
    C<include_type_name>,
    C<local>,
    C<master_timeout>

=head2 C<exists()>

    $bool = $e->indices->exists(
        index => 'index' | \@indices    # required
    );

The C<exists()> method returns C<1> or the empty string to indicate
whether the specified index or indices exist.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<flat_settings>,
    C<human>,
    C<ignore_unavailable>,
    C<include_defaults>,
    C<local>

See the L<index exists docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-indices-exists.html>
for more information.

=head2 C<delete()>

    $response = $e->indices->delete(
        index => 'index' | \@indices    # required
    );

The C<delete()> method deletes the specified indices.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<master_timeout>,
    C<timeout>

See the L<delete index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-delete-index.html>
for more information.

=head2 C<close()>

    $response = $e->indices->close(
        index => 'index' | \@indices    # required
    );

The C<close()> method closes the specified indices, reducing resource usage
but allowing them to be reopened later.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>
    C<master_timeout>,
    C<timeout>

See the L<close index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html>
for more information.

=head2 C<open()>

    $response = $e->indices->open(
        index => 'index' | \@indices    # required
    );

The C<open()> method opens closed indices.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>
    C<master_timeout>,
    C<timeout>,
    C<wait_for_active_shards>

See the L<open index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html>
for more information.

=head2 C<rollover()>

    $response = $e->indices->rollover(
        alias     => $alias,                    # required
        new_index => $index,                    # optional
        body      => { rollover conditions }    # optional
    );

Rollover an index pointed to by C<alias> if it meets rollover conditions
(eg max age, max docs) to a new index name.

Query string parameters:
    C<dry_run>,
    C<error_trace>,
    C<human>,
    C<include_type_name>,
    C<master_timeout>,
    C<timeout>,
    C<wait_for_active_shards>

See the L<rollover index docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-rollover-index.html>
for more information.

=head2 C<shrink()>

    $response = $e->shrink(
        index  => $index,                           # required
        target => $target,                          # required
        body   => { mappings, settings aliases }    # optional
    );

The shrink API shrinks the shards of an index down to a single shard (or to a factor
of the original shards).

Query string parameters:
    C<copy_settings>,
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<master_timeout>,
    C<timeout>,
    C<wait_for_active_shards>

See the L<shrink index docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-shrink-index.html>
for more information.

=head2 C<split()>

    $response = $e->split(
        index  => $index,                           # required
        target => $target,                          # required
    );

The split API splits a shard into multiple shards.

Query string parameters:
    C<copy_settings>,
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<master_timeout>,
    C<timeout>,
    C<wait_for_active_shards>

See the L<split index docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-split-index.html>
for more information.

=head2 C<freeze()>

    $response = $e->indices->freeze(
        $index => $index    # required
    );

The C<freeze()> API is used to freeze an index, which puts it in a state which has almost no
overhead on the cluster.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<filter_path>,
    C<human>,
    C<ignore_unavailable>,
    C<master_timeout>,
    C<timeout>,
    C<wait_for_active_shards>

See the L<freeze index docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/freeze-index-api.html>
for more information.

=head2 C<unfreeze()>

    $response = $e->indices->unfreeze(
        $index => $index    # required
    );

The C<unfreeze()> API is used to return a frozen index to its normal state.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<filter_path>,
    C<human>,
    C<ignore_unavailable>,
    C<master_timeout>,
    C<timeout>,
    C<wait_for_active_shards>

See the L<unfreeze index docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/freeze-index-api.html>
for more information.

=head2 C<clear_cache()>

    $response = $e->indices->clear_cache(
        index => 'index' | \@indices        # optional
    );

The C<clear_cache()> method is used to clear the in-memory filter, fielddata,
or id cache for the specified indices.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<fielddata>,
    C<fields>,
    C<human>,
    C<ignore_unavailable>,
    C<query>,
    C<request>

See the L<clear_cache docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-clearcache.html>
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
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>

See the L<refresh index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html>
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
    C<error_trace>,
    C<expand_wildcards>,
    C<force>,
    C<human>,
    C<ignore_unavailable>,
    C<wait_if_ongoing>

See the L<flush index docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-flush.html>
for more information.

=head2 C<flush_synced()>

    $respnse = $e->indices->flush_synced(
        index => 'index' | \@indices    # optional
    );

The C<flush_synced()> method does a synchronised L<flush()> on the primaries and replicas of
all the specified indices.  In other words, after flushing it tries to write a C<sync_id>
on the primaries and replicas to mark them as containing the same documents.  During
recovery, if a replica has the same C<sync_id> as the primary, then it doesn't need to check
whether the segment files on primary and replica are the same, and it can move on
directly to just replaying the translog.  This can greatly speed up recovery.

Synced flushes happens automatically in the background on indices that have not received any
writes for a while, but the L<flush_synced()> method can be used to trigger this process
manually, eg before shutting down.  Any new commits immediately break the sync.

See the L<flush synced docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-synced-flush.html>
for more information.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>

=head2 C<forcemerge()>

    $response = $e->indices->forcemerge(
        index => 'index' | \@indices    # optional
    );

The C<forcemerge()> method rewrites all the data in an index into at most
C<max_num_segments>.  This is a very heavy operation and should only be run
with care, and only on indices that are no longer being updated.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<flush>,
    C<human>,
    C<ignore_unavailable>,
    C<max_num_segments>,
    C<only_expunge_deletes>

See the L<forcemerge docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html>
for more information.

=head2 C<get_upgrade()>

    $response = $e->indices->get_upgrade(
        index => 'index' | \@indices    # optional
    );

The C<get_upgrade()> method returns information about which indices need to be
upgraded, which can be done with the C<upgrade()> method.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>

See the L<upgrade docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-upgrade.html>
for more information.

=head2 C<upgrade()>

    $response = $e->indices->upgrade(
        index => 'index' | \@indices    # optional
    );

The C<upgrade()> method upgrades all segments in the specified indices to the latest format.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<only_ancient_segments>,
    C<wait_for_completion>

See the L<upgrade docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-upgrade.html>
for more information.

=head1 MAPPING METHODS

=head2 C<put_mapping()>

    $response = $e->indices->put_mapping(
        index => 'index' | \@indices    # optional,
        type  => 'type',                # optional

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
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<include_type_name>,
    C<master_timeout>,
    C<timeout>,
    C<update_all_types>

See the L<put_mapping docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html>
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
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<include_type_name>,
    C<local>,
    C<master_timeout>

See the L<get_mapping docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-mapping.html>
for more information.

=head2 C<get_field_mapping()>

    $result = $e->indices->get_field_mapping(
        index => 'index'  | \@indices    # optional,
        type  => 'type'   | \@types      # optional,
        fields => 'field' | \@fields     # required

        include_defaults => 0 | 1
    );

The C<get_field_mapping()> method returns the field definitions for one, more or
all fields in one, more or all types and indices.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<include_defaults>,
    C<include_type_name>,
    C<local>

See the L<get_mapping docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-field-mapping.html>
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
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<local>

See the L<exists_type docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-types-exists.html>
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
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>

See the L<update_aliases docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<put_alias()>

    $response = $e->indices->put_alias(
        index => 'index' | \@indices,       # required
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
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>

See the L<put_alias docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html>
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
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<local>

See the L<get_alias docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<exists_alias()>

    $bool = $e->indices->exists_alias(
        index   => 'index' | \@indices,     # optional
        name    => 'alias' | \@aliases      # required
    );

The C<exists_alias()> method returns C<1> or the empty string depending on
whether the specified aliases exist in the specified indices.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<local>

See the L<exists_alias docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html>
for more information.

=head2 C<delete_alias()>

    $response = $e->indices->delete_alias(
        index   => 'index' | \@indices        # required,
        name    => 'alias' | \@aliases        # required
    );

The C<delete_alias()> method deletes one or more aliases from one or more
indices.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>

See the L<delete_alias docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-aliases.html>
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
    C<error_trace>,
    C<expand_wildcards>,
    C<flat_settings>,
    C<human>,
    C<ignore_unavailable>,
    C<master_timeout>,
    C<preserve_existing>,
    C<timeout>

See the L<put_settings docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html>
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
    C<error_trace>,
    C<expand_wildcards>,
    C<flat_settings>,
    C<human>,
    C<ignore_unavailable>,
    C<include_defaults>,
    C<local>,
    C<master_timeout>

See the L<get_settings docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-settings.html>
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
    C<error_trace>,
    C<flat_settings>,
    C<human>,
    C<include_type_name>,
    C<master_timeout>,
    C<order>,
    C<timeout>

See the L<put_template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html>
for more information.

=head2 C<get_template()>

    $result = $e->indices->get_template(
        name  => 'template' | \@templates # optional
    );

The C<get_template()> method is used to retrieve a named template.

Query string parameters:
    C<error_trace>,
    C<flat_settings>,
    C<human>,
    C<include_type_name>,
    C<local>,
    C<master_timeout>

See the L<get_template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html>
for more information.

=head2 C<exists_template()>

    $result = $e->indices->exists_template(
        name  => 'template'                 # optional
    );

The C<exists_template()> method is used to check whether the named template exists.

Query string parameters:
    C<error_trace>,
    C<flat_settings>,
    C<human>,
    C<local>,
    C<master_timeout>

See the L<get_template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html>
for more information.

=head2 C<delete_template()>

    $response = $e->indices->delete_template(
        name  => 'template'                 # required
    );

The C<delete_template()> method is used to delete a named template.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>,
    C<version>,
    C<version_type>

See the L<delete_template docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-templates.html>
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
    C<request_cache>,
    C<search>,
    C<segments>,
    C<store>


Query string parameters:
    C<completion_fields>,
    C<error_trace>,
    C<fielddata_fields>,
    C<fields>,
    C<groups>,
    C<human>,
    C<include_segment_file_sizes>,
    C<level>,
    C<types>

See the L<stats docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-stats.html>
for more information.

=head2 C<recovery()>

    $result = $e->indices->recovery(
        index   => 'index' | \@indices      # optional
    );

Provides insight into on-going shard recoveries.

Query string parameters:
    C<active_only>,
    C<detailed>,
    C<error_trace>,
    C<human>

See the L<recovery docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-recovery.html>
for more information.

=head2 C<segments()>

    $result = $e->indices->segments(
        index   => 'index' | \@indices      # optional
    );

The C<segments()> method is used to return information about the segments
that an index contains.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<verbose>

See the L<segments docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-segments.html>
for more information.

=head2 C<shard_stores()>

    $result = $e->indices->shard_stores(
        index   => 'index' | \@indices      # optional
    );

The C<shard_stores()> method is used to find out which nodes contain
copies of which shards, whether the shards are allocated or not.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>,
    C<status>

See the L<shard_stores docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-shards-stores.html>
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
    C<error_trace>,
    C<human>

See the L<analyze docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html>
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
    C<all_shards>,
    C<allow_no_indices>,
    C<analyze_wildcard>,
    C<analyzer>,
    C<default_operator>,
    C<df>,
    C<error_trace>,
    C<explain>,
    C<expand_wildcards>,
    C<ignore_unavailable>,
    C<lenient>,
    C<q>,
    C<rewrite>

See the L<validate_query docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/indices-validate.html>
for more information.



