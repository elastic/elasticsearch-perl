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

package Search::Elasticsearch::Client::7_0::Role::API;

use Moo::Role;
with 'Search::Elasticsearch::Role::API';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

has 'api_version' => ( is => 'ro', default => '7_0' );

our %API;

#===================================
sub api {
#===================================
    my $name = $_[1] || return \%API;
    return $API{$name}
        || throw( 'Internal', "Unknown api name ($name)" );
}

#===================================
%API = (
#===================================

    'bulk.metadata' => {
        params => {
            '_index'                 => '_index',
            'index'                  => '_index',
            '_id'                    => '_id',
            'id'                     => '_id',
            'pipeline'               => 'pipeline',
            'routing'                => 'routing',
            '_routing'               => 'routing',
            'parent'                 => 'parent',
            '_parent'                => 'parent',
            'timestamp'              => 'timestamp',
            '_timestamp'             => 'timestamp',
            'ttl'                    => 'ttl',
            '_ttl'                   => 'ttl',
            'version'                => 'version',
            '_version'               => 'version',
            'version_type'           => 'version_type',
            '_version_type'          => 'version_type',
            'if_seq_no'              => 'if_seq_no',
            'if_primary_term'        => 'if_primary_term',
            'lang'                   => 'lang',
            'require_alias'          => 'require_alias',
            'refresh'                => 'refresh',
            'retry_on_conflict'      => 'retru_on_conflict',
            'wait_for_active_shards' => 'wait_for_active_shards',
            '_source'                => '_source',
            '_source_excludes'       => '_source_excludes',
            '_source_includes'       => '_source_includes',
            'timeout'                => 'timeout'
        }
    },
    'bulk.update' => {
        params => [
            '_source',          '_source_includes',
            '_source_excludes', 'detect_noop',
            'doc',              'doc_as_upsert',
            'fields',           'retry_on_conflict',
            'scripted_upsert',  'script',
            'upsert',           'lang',
            'params'
        ]
    },
    'bulk.required' => { params => ['index'] },

#=== AUTOGEN - START ===

    'bulk' => {
        body   => { required => 1 },
        doc    => "docs-bulk",
        method => "POST",
        parts  => { index => {}, type => {} },
        paths  => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_bulk" ],
            [ { index => 0 }, "{index}", "_bulk" ],
            [ {}, "_bulk" ],
        ],
        qs => {
            _source                => "list",
            _source_excludes       => "list",
            _source_includes       => "list",
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            pipeline               => "string",
            refresh                => "enum",
            require_alias          => "boolean",
            routing                => "string",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
        serialize => "bulk",
    },

    'clear_scroll' => {
        body   => {},
        doc    => "clear-scroll-api",
        method => "DELETE",
        parts  => { scroll_id => { multi => 1 } },
        paths  => [
            [ { scroll_id => 2 }, "_search", "scroll", "{scroll_id}" ],
            [ {}, "_search", "scroll" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'close_point_in_time' => {
        body   => {},
        doc    => "point-in-time-api",
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_pit" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'count' => {
        body   => {},
        doc    => "search-count",
        method => "POST",
        parts  => { index => { multi => 1 }, type => { multi => 1 } },
        paths  => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_count" ],
            [ { index => 0 }, "{index}", "_count" ],
            [ {}, "_count" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            analyze_wildcard   => "boolean",
            analyzer           => "string",
            default_operator   => "enum",
            df                 => "string",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_throttled   => "boolean",
            ignore_unavailable => "boolean",
            lenient            => "boolean",
            min_score          => "number",
            preference         => "string",
            q                  => "string",
            routing            => "list",
            terminate_after    => "number",
        },
    },

    'create' => {
        body   => { required => 1 },
        doc    => "docs-index_",
        method => "PUT",
        parts  => { id => {}, index => {}, type => {} },
        paths  => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_create",
            ],
            [ { id => 2, index => 0 }, "{index}", "_create", "{id}" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            pipeline               => "string",
            refresh                => "enum",
            routing                => "string",
            timeout                => "time",
            version                => "number",
            version_type           => "enum",
            wait_for_active_shards => "string",
        },
    },

    'delete' => {
        doc    => "docs-delete",
        method => "DELETE",
        parts  => { id => {}, index => {}, type => {} },
        paths  => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",                           "{id}"
            ],
            [ { id => 2, index => 0 }, "{index}", "_doc", "{id}" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            if_primary_term        => "number",
            if_seq_no              => "number",
            refresh                => "enum",
            routing                => "string",
            timeout                => "time",
            version                => "number",
            version_type           => "enum",
            wait_for_active_shards => "string",
        },
    },

    'delete_by_query' => {
        body   => { required => 1 },
        doc    => "docs-delete-by-query",
        method => "POST",
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1 }
        },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_delete_by_query",
            ],
            [ { index => 0 }, "{index}", "_delete_by_query" ],
        ],
        qs => {
            _source                => "list",
            _source_excludes       => "list",
            _source_includes       => "list",
            allow_no_indices       => "boolean",
            analyze_wildcard       => "boolean",
            analyzer               => "string",
            conflicts              => "enum",
            default_operator       => "enum",
            df                     => "string",
            error_trace            => "boolean",
            expand_wildcards       => "enum",
            filter_path            => "list",
            from                   => "number",
            human                  => "boolean",
            ignore_unavailable     => "boolean",
            lenient                => "boolean",
            max_docs               => "number",
            preference             => "string",
            q                      => "string",
            refresh                => "boolean",
            request_cache          => "boolean",
            requests_per_second    => "number",
            routing                => "list",
            scroll                 => "time",
            scroll_size            => "number",
            search_timeout         => "time",
            search_type            => "enum",
            size                   => "number",
            slices                 => "number|string",
            sort                   => "list",
            stats                  => "list",
            terminate_after        => "number",
            timeout                => "time",
            version                => "boolean",
            wait_for_active_shards => "string",
            wait_for_completion    => "boolean",
        },
    },

    'delete_by_query_rethrottle' => {
        doc    => "docs-delete-by-query",
        method => "POST",
        parts  => { task_id => {} },
        paths  => [
            [   { task_id => 1 }, "_delete_by_query",
                "{task_id}",      "_rethrottle",
            ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            requests_per_second => "number",
        },
    },

    'delete_script' => {
        doc    => "modules-scripting",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 1 }, "_scripts", "{id}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'exists' => {
        doc    => "docs-get",
        method => "HEAD",
        parts  => { id => {}, index => {}, type => {} },
        paths  => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",                           "{id}"
            ],
            [ { id => 2, index => 0 }, "{index}", "_doc", "{id}" ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            preference       => "string",
            realtime         => "boolean",
            refresh          => "boolean",
            routing          => "string",
            stored_fields    => "list",
            version          => "number",
            version_type     => "enum",
        },
    },

    'exists_source' => {
        doc    => "docs-get",
        method => "HEAD",
        parts  => { id => {}, index => {}, type => {} },
        paths  => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_source",
            ],
            [ { id => 2, index => 0 }, "{index}", "_source", "{id}" ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            preference       => "string",
            realtime         => "boolean",
            refresh          => "boolean",
            routing          => "string",
            version          => "number",
            version_type     => "enum",
        },
    },

    'explain' => {
        body  => {},
        doc   => "search-explain",
        parts => { id => {}, index => {}, type => {} },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",                           "{id}",
                "_explain",
            ],
            [ { id => 2, index => 0 }, "{index}", "_explain", "{id}" ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            analyze_wildcard => "boolean",
            analyzer         => "string",
            default_operator => "enum",
            df               => "string",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            lenient          => "boolean",
            preference       => "string",
            q                => "string",
            routing          => "string",
            stored_fields    => "list",
        },
    },

    'field_caps' => {
        body  => {},
        doc   => "search-field-caps",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_field_caps" ],
            [ {}, "_field_caps" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            fields             => "list",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            include_unmapped   => "boolean",
        },
    },

    'get' => {
        doc   => "docs-get",
        parts => { id => {}, index => {}, type => {} },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",                           "{id}"
            ],
            [ { id => 2, index => 0 }, "{index}", "_doc", "{id}" ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            preference       => "string",
            realtime         => "boolean",
            refresh          => "boolean",
            routing          => "string",
            stored_fields    => "list",
            version          => "number",
            version_type     => "enum",
        },
    },

    'get_script' => {
        doc   => "modules-scripting",
        parts => { id => {} },
        paths => [ [ { id => 1 }, "_scripts", "{id}" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'get_script_context' => {
        doc   => "painless-contexts",
        parts => {},
        paths => [ [ {}, "_script_context" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'get_script_languages' => {
        doc   => "modules-scripting",
        parts => {},
        paths => [ [ {}, "_script_language" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'get_source' => {
        doc   => "docs-get",
        parts => { id => {}, index => {}, type => {} },
        paths => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_source",
            ],
            [ { id => 2, index => 0 }, "{index}", "_source", "{id}" ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            preference       => "string",
            realtime         => "boolean",
            refresh          => "boolean",
            routing          => "string",
            version          => "number",
            version_type     => "enum",
        },
    },

    'index' => {
        body   => { required => 1 },
        doc    => "docs-index_",
        method => "POST",
        parts  => { id => {}, index => {}, type => {} },
        paths  => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",                           "{id}"
            ],
            [ { id    => 2, index => 0 }, "{index}", "_doc", "{id}" ],
            [ { index => 0, type  => 1 }, "{index}", "{type}" ],
            [ { index => 0 }, "{index}", "_doc" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            if_primary_term        => "number",
            if_seq_no              => "number",
            op_type                => "enum",
            pipeline               => "string",
            refresh                => "enum",
            require_alias          => "boolean",
            routing                => "string",
            timeout                => "time",
            version                => "number",
            version_type           => "enum",
            wait_for_active_shards => "string",
        },
    },

    'info' => {
        doc   => "index",
        parts => {},
        paths => [ [ {} ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'mget' => {
        body  => { required => 1 },
        doc   => "docs-multi-get",
        parts => { index => {}, type => {} },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mget" ],
            [ { index => 0 }, "{index}", "_mget" ],
            [ {}, "_mget" ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            preference       => "string",
            realtime         => "boolean",
            refresh          => "boolean",
            routing          => "string",
            stored_fields    => "list",
        },
    },

    'msearch' => {
        body  => { required => 1 },
        doc   => "search-multi-search",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_msearch" ],
            [ { index => 0 }, "{index}", "_msearch" ],
            [ {}, "_msearch" ],
        ],
        qs => {
            ccs_minimize_roundtrips       => "boolean",
            error_trace                   => "boolean",
            filter_path                   => "list",
            human                         => "boolean",
            max_concurrent_searches       => "number",
            max_concurrent_shard_requests => "number",
            pre_filter_shard_size         => "number",
            rest_total_hits_as_int        => "boolean",
            search_type                   => "enum",
            typed_keys                    => "boolean",
        },
        serialize => "bulk",
    },

    'msearch_template' => {
        body  => { required => 1 },
        doc   => "search-multi-search",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_msearch",
                "template",
            ],
            [ { index => 0 }, "{index}", "_msearch", "template" ],
            [ {}, "_msearch", "template" ],
        ],
        qs => {
            ccs_minimize_roundtrips => "boolean",
            error_trace             => "boolean",
            filter_path             => "list",
            human                   => "boolean",
            max_concurrent_searches => "number",
            rest_total_hits_as_int  => "boolean",
            search_type             => "enum",
            typed_keys              => "boolean",
        },
        serialize => "bulk",
    },

    'mtermvectors' => {
        body  => {},
        doc   => "docs-multi-termvectors",
        parts => { index => {}, type => {} },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_mtermvectors"
            ],
            [ { index => 0 }, "{index}", "_mtermvectors" ],
            [ {}, "_mtermvectors" ],
        ],
        qs => {
            error_trace      => "boolean",
            field_statistics => "boolean",
            fields           => "list",
            filter_path      => "list",
            human            => "boolean",
            ids              => "list",
            offsets          => "boolean",
            payloads         => "boolean",
            positions        => "boolean",
            preference       => "string",
            realtime         => "boolean",
            routing          => "string",
            term_statistics  => "boolean",
            version          => "number",
            version_type     => "enum",
        },
    },

    'open_point_in_time' => {
        doc    => "point-in-time-api",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_pit" ], [ {}, "_pit" ] ],
        qs     => {
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            keep_alive         => "string",
            preference         => "string",
            routing            => "string",
        },
    },

    'ping' => {
        doc    => "index",
        method => "HEAD",
        parts  => {},
        paths  => [ [ {} ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'put_script' => {
        body   => { required => 1 },
        doc    => "modules-scripting",
        method => "PUT",
        parts  => { context => {}, id => {} },
        paths  => [
            [ { context => 2, id => 1 }, "_scripts", "{id}", "{context}" ],
            [ { id => 1 }, "_scripts", "{id}" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'rank_eval' => {
        body  => { required => 1 },
        doc   => "search-rank-eval",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_rank_eval" ],
            [ {}, "_rank_eval" ]
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            search_type        => "enum",
        },
    },

    'reindex' => {
        body   => { required => 1 },
        doc    => "docs-reindex",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_reindex" ] ],
        qs     => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            max_docs               => "number",
            refresh                => "boolean",
            requests_per_second    => "number",
            scroll                 => "time",
            slices                 => "number|string",
            timeout                => "time",
            wait_for_active_shards => "string",
            wait_for_completion    => "boolean",
        },
    },

    'reindex_rethrottle' => {
        doc    => "docs-reindex",
        method => "POST",
        parts  => { task_id => {} },
        paths  =>
            [ [ { task_id => 1 }, "_reindex", "{task_id}", "_rethrottle" ] ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            requests_per_second => "number",
        },
    },

    'render_search_template' => {
        body  => {},
        doc   => "",
        parts => { id => {} },
        paths => [
            [ { id => 2 }, "_render", "template", "{id}" ],
            [ {}, "_render", "template" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'scripts_painless_execute' => {
        body  => {},
        doc   => "painless-execute-api",
        parts => {},
        paths => [ [ {}, "_scripts", "painless", "_execute" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'scroll' => {
        body  => {},
        doc   => "",
        parts => { scroll_id => {} },
        paths => [
            [ { scroll_id => 2 }, "_search", "scroll", "{scroll_id}" ],
            [ {}, "_search", "scroll" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            rest_total_hits_as_int => "boolean",
            scroll                 => "time",
        },
    },

    'search' => {
        body  => {},
        doc   => "search-search",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_search" ],
            [ { index => 0 }, "{index}", "_search" ],
            [ {}, "_search" ],
        ],
        qs => {
            _source                       => "list",
            _source_excludes              => "list",
            _source_includes              => "list",
            allow_no_indices              => "boolean",
            allow_partial_search_results  => "boolean",
            analyze_wildcard              => "boolean",
            analyzer                      => "string",
            batched_reduce_size           => "number",
            ccs_minimize_roundtrips       => "boolean",
            default_operator              => "enum",
            df                            => "string",
            docvalue_fields               => "list",
            error_trace                   => "boolean",
            expand_wildcards              => "enum",
            explain                       => "boolean",
            filter_path                   => "list",
            from                          => "number",
            human                         => "boolean",
            ignore_throttled              => "boolean",
            ignore_unavailable            => "boolean",
            lenient                       => "boolean",
            max_concurrent_shard_requests => "number",
            min_compatible_shard_node     => "string",
            pre_filter_shard_size         => "number",
            preference                    => "string",
            q                             => "string",
            request_cache                 => "boolean",
            rest_total_hits_as_int        => "boolean",
            routing                       => "list",
            scroll                        => "time",
            search_type                   => "enum",
            seq_no_primary_term           => "boolean",
            size                          => "number",
            sort                          => "list",
            stats                         => "list",
            stored_fields                 => "list",
            suggest_field                 => "string",
            suggest_mode                  => "enum",
            suggest_size                  => "number",
            suggest_text                  => "string",
            terminate_after               => "number",
            timeout                       => "time",
            track_scores                  => "boolean",
            track_total_hits              => "boolean",
            typed_keys                    => "boolean",
            version                       => "boolean",
        },
    },

    'search_shards' => {
        doc   => "search-shards",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_search_shards" ],
            [ {}, "_search_shards" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            local              => "boolean",
            preference         => "string",
            routing            => "string",
        },
    },

    'search_template' => {
        body  => { required => 1 },
        doc   => "search-template",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_search",
                "template",
            ],
            [ { index => 0 }, "{index}", "_search", "template" ],
            [ {}, "_search", "template" ],
        ],
        qs => {
            allow_no_indices        => "boolean",
            ccs_minimize_roundtrips => "boolean",
            error_trace             => "boolean",
            expand_wildcards        => "enum",
            explain                 => "boolean",
            filter_path             => "list",
            human                   => "boolean",
            ignore_throttled        => "boolean",
            ignore_unavailable      => "boolean",
            preference              => "string",
            profile                 => "boolean",
            rest_total_hits_as_int  => "boolean",
            routing                 => "list",
            scroll                  => "time",
            search_type             => "enum",
            typed_keys              => "boolean",
        },
    },

    'termvectors' => {
        body  => {},
        doc   => "docs-termvectors",
        parts => { id => {}, index => { required => 1 }, type => {} },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",                           "{id}",
                "_termvectors",
            ],
            [ { id => 2, index => 0 }, "{index}", "_termvectors", "{id}" ],
            [   { index => 0, type => 1 }, "{index}", "{type}",
                "_termvectors"
            ],
            [ { index => 0 }, "{index}", "_termvectors" ],
        ],
        qs => {
            error_trace      => "boolean",
            field_statistics => "boolean",
            fields           => "list",
            filter_path      => "list",
            human            => "boolean",
            offsets          => "boolean",
            payloads         => "boolean",
            positions        => "boolean",
            preference       => "string",
            realtime         => "boolean",
            routing          => "string",
            term_statistics  => "boolean",
            version          => "number",
            version_type     => "enum",
        },
    },

    'update' => {
        body   => { required => 1 },
        doc    => "docs-update",
        method => "POST",
        parts  => { id => {}, index => {}, type => {} },
        paths  => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_update",
            ],
            [ { id => 2, index => 0 }, "{index}", "_update", "{id}" ],
        ],
        qs => {
            _source                => "list",
            _source_excludes       => "list",
            _source_includes       => "list",
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            if_primary_term        => "number",
            if_seq_no              => "number",
            lang                   => "string",
            refresh                => "enum",
            require_alias          => "boolean",
            retry_on_conflict      => "number",
            routing                => "string",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'update_by_query' => {
        body   => {},
        doc    => "docs-update-by-query",
        method => "POST",
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1 }
        },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_update_by_query",
            ],
            [ { index => 0 }, "{index}", "_update_by_query" ],
        ],
        qs => {
            _source                => "list",
            _source_excludes       => "list",
            _source_includes       => "list",
            allow_no_indices       => "boolean",
            analyze_wildcard       => "boolean",
            analyzer               => "string",
            conflicts              => "enum",
            default_operator       => "enum",
            df                     => "string",
            error_trace            => "boolean",
            expand_wildcards       => "enum",
            filter_path            => "list",
            from                   => "number",
            human                  => "boolean",
            ignore_unavailable     => "boolean",
            lenient                => "boolean",
            max_docs               => "number",
            pipeline               => "string",
            preference             => "string",
            q                      => "string",
            refresh                => "boolean",
            request_cache          => "boolean",
            requests_per_second    => "number",
            routing                => "list",
            scroll                 => "time",
            scroll_size            => "number",
            search_timeout         => "time",
            search_type            => "enum",
            size                   => "number",
            slices                 => "number|string",
            sort                   => "list",
            stats                  => "list",
            terminate_after        => "number",
            timeout                => "time",
            version                => "boolean",
            version_type           => "boolean",
            wait_for_active_shards => "string",
            wait_for_completion    => "boolean",
        },
    },

    'update_by_query_rethrottle' => {
        doc    => "docs-update-by-query",
        method => "POST",
        parts  => { task_id => {} },
        paths  => [
            [   { task_id => 1 }, "_update_by_query",
                "{task_id}",      "_rethrottle",
            ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            requests_per_second => "number",
        },
    },

    'async_search.delete' => {
        doc    => "async-search",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 1 }, "_async_search", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'async_search.get' => {
        doc   => "async-search",
        parts => { id => {} },
        paths => [ [ { id => 1 }, "_async_search", "{id}" ] ],
        qs    => {
            error_trace                 => "boolean",
            filter_path                 => "list",
            human                       => "boolean",
            keep_alive                  => "time",
            typed_keys                  => "boolean",
            wait_for_completion_timeout => "time",
        },
    },

    'async_search.status' => {
        doc   => "async-search",
        parts => { id => {} },
        paths => [ [ { id => 2 }, "_async_search", "status", "{id}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'async_search.submit' => {
        body   => {},
        doc    => "async-search",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_async_search" ],
            [ {}, "_async_search" ],
        ],
        qs => {
            _source                       => "list",
            _source_excludes              => "list",
            _source_includes              => "list",
            allow_no_indices              => "boolean",
            allow_partial_search_results  => "boolean",
            analyze_wildcard              => "boolean",
            analyzer                      => "string",
            batched_reduce_size           => "number",
            default_operator              => "enum",
            df                            => "string",
            docvalue_fields               => "list",
            error_trace                   => "boolean",
            expand_wildcards              => "enum",
            explain                       => "boolean",
            filter_path                   => "list",
            from                          => "number",
            human                         => "boolean",
            ignore_throttled              => "boolean",
            ignore_unavailable            => "boolean",
            keep_alive                    => "time",
            keep_on_completion            => "boolean",
            lenient                       => "boolean",
            max_concurrent_shard_requests => "number",
            preference                    => "string",
            q                             => "string",
            request_cache                 => "boolean",
            routing                       => "list",
            search_type                   => "enum",
            seq_no_primary_term           => "boolean",
            size                          => "number",
            sort                          => "list",
            stats                         => "list",
            stored_fields                 => "list",
            suggest_field                 => "string",
            suggest_mode                  => "enum",
            suggest_size                  => "number",
            suggest_text                  => "string",
            terminate_after               => "number",
            timeout                       => "time",
            track_scores                  => "boolean",
            track_total_hits              => "boolean",
            typed_keys                    => "boolean",
            version                       => "boolean",
            wait_for_completion_timeout   => "time",
        },
    },

    'autoscaling.delete_autoscaling_policy' => {
        doc    => "autoscaling-delete-autoscaling-policy",
        method => "DELETE",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_autoscaling", "policy", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'autoscaling.get_autoscaling_capacity' => {
        doc   => "autoscaling-get-autoscaling-capacity",
        parts => {},
        paths => [ [ {}, "_autoscaling", "capacity" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'autoscaling.get_autoscaling_policy' => {
        doc   => "autoscaling-get-autoscaling-policy",
        parts => { name => {} },
        paths => [ [ { name => 2 }, "_autoscaling", "policy", "{name}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'autoscaling.put_autoscaling_policy' => {
        body   => { required => 1 },
        doc    => "autoscaling-put-autoscaling-policy",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_autoscaling", "policy", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'cat.aliases' => {
        doc   => "cat-alias",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 2 }, "_cat", "aliases", "{name}" ],
            [ {}, "_cat", "aliases" ],
        ],
        qs => {
            error_trace      => "boolean",
            expand_wildcards => "enum",
            filter_path      => "list",
            format           => "string",
            h                => "list",
            help             => "boolean",
            human            => "boolean",
            local            => "boolean",
            s                => "list",
            v                => "boolean",
        },
    },

    'cat.allocation' => {
        doc   => "cat-allocation",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 2 }, "_cat", "allocation", "{node_id}" ],
            [ {}, "_cat", "allocation" ],
        ],
        qs => {
            bytes          => "enum",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            v              => "boolean",
        },
    },

    'cat.count' => {
        doc   => "cat-count",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "count", "{index}" ],
            [ {}, "_cat", "count" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            h           => "list",
            help        => "boolean",
            human       => "boolean",
            s           => "list",
            v           => "boolean",
        },
    },

    'cat.fielddata' => {
        doc   => "cat-fielddata",
        parts => { fields => { multi => 1 } },
        paths => [
            [ { fields => 2 }, "_cat", "fielddata", "{fields}" ],
            [ {}, "_cat", "fielddata" ],
        ],
        qs => {
            bytes       => "enum",
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            h           => "list",
            help        => "boolean",
            human       => "boolean",
            s           => "list",
            v           => "boolean",
        },
    },

    'cat.health' => {
        doc   => "cat-health",
        parts => {},
        paths => [ [ {}, "_cat", "health" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            h           => "list",
            help        => "boolean",
            human       => "boolean",
            s           => "list",
            time        => "enum",
            ts          => "boolean",
            v           => "boolean",
        },
    },

    'cat.help' => {
        doc   => "cat",
        parts => {},
        paths => [ [ {}, "_cat" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            help        => "boolean",
            human       => "boolean",
            s           => "list",
        },
    },

    'cat.indices' => {
        doc   => "cat-indices",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "indices", "{index}" ],
            [ {}, "_cat", "indices" ],
        ],
        qs => {
            bytes                     => "enum",
            error_trace               => "boolean",
            expand_wildcards          => "enum",
            filter_path               => "list",
            format                    => "string",
            h                         => "list",
            health                    => "enum",
            help                      => "boolean",
            human                     => "boolean",
            include_unloaded_segments => "boolean",
            local                     => "boolean",
            master_timeout            => "time",
            pri                       => "boolean",
            s                         => "list",
            time                      => "enum",
            v                         => "boolean",
        },
    },

    'cat.master' => {
        doc   => "cat-master",
        parts => {},
        paths => [ [ {}, "_cat", "master" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            v              => "boolean",
        },
    },

    'cat.ml_data_frame_analytics' => {
        doc   => "cat-dfanalytics",
        parts => { id => {} },
        paths => [
            [ { id => 4 }, "_cat", "ml", "data_frame", "analytics", "{id}" ],
            [ {}, "_cat", "ml", "data_frame", "analytics" ],
        ],
        qs => {
            allow_no_match => "boolean",
            bytes          => "enum",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            s              => "list",
            time           => "enum",
            v              => "boolean",
        },
    },

    'cat.ml_datafeeds' => {
        doc   => "cat-datafeeds",
        parts => { datafeed_id => {} },
        paths => [
            [   { datafeed_id => 3 }, "_cat",
                "ml",                 "datafeeds",
                "{datafeed_id}"
            ],
            [ {}, "_cat", "ml", "datafeeds" ],
        ],
        qs => {
            allow_no_datafeeds => "boolean",
            allow_no_match     => "boolean",
            error_trace        => "boolean",
            filter_path        => "list",
            format             => "string",
            h                  => "list",
            help               => "boolean",
            human              => "boolean",
            s                  => "list",
            time               => "enum",
            v                  => "boolean",
        },
    },

    'cat.ml_jobs' => {
        doc   => "cat-anomaly-detectors",
        parts => { job_id => {} },
        paths => [
            [   { job_id => 3 }, "_cat", "ml", "anomaly_detectors",
                "{job_id}"
            ],
            [ {}, "_cat", "ml", "anomaly_detectors" ],
        ],
        qs => {
            allow_no_jobs  => "boolean",
            allow_no_match => "boolean",
            bytes          => "enum",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            s              => "list",
            time           => "enum",
            v              => "boolean",
        },
    },

    'cat.ml_trained_models' => {
        doc   => "cat-trained-model",
        parts => { model_id => {} },
        paths => [
            [   { model_id => 3 }, "_cat",
                "ml",              "trained_models",
                "{model_id}"
            ],
            [ {}, "_cat", "ml", "trained_models" ],
        ],
        qs => {
            allow_no_match => "boolean",
            bytes          => "enum",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            from           => "int",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            s              => "list",
            size           => "int",
            time           => "enum",
            v              => "boolean",
        },
    },

    'cat.nodeattrs' => {
        doc   => "cat-nodeattrs",
        parts => {},
        paths => [ [ {}, "_cat", "nodeattrs" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            v              => "boolean",
        },
    },

    'cat.nodes' => {
        doc   => "cat-nodes",
        parts => {},
        paths => [ [ {}, "_cat", "nodes" ] ],
        qs    => {
            bytes                     => "enum",
            error_trace               => "boolean",
            filter_path               => "list",
            format                    => "string",
            full_id                   => "boolean",
            h                         => "list",
            help                      => "boolean",
            human                     => "boolean",
            include_unloaded_segments => "boolean",
            local                     => "boolean",
            master_timeout            => "time",
            s                         => "list",
            time                      => "enum",
            v                         => "boolean",
        },
    },

    'cat.pending_tasks' => {
        doc   => "cat-pending-tasks",
        parts => {},
        paths => [ [ {}, "_cat", "pending_tasks" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            time           => "enum",
            v              => "boolean",
        },
    },

    'cat.plugins' => {
        doc   => "cat-plugins",
        parts => {},
        paths => [ [ {}, "_cat", "plugins" ] ],
        qs    => {
            error_trace       => "boolean",
            filter_path       => "list",
            format            => "string",
            h                 => "list",
            help              => "boolean",
            human             => "boolean",
            include_bootstrap => "boolean",
            local             => "boolean",
            master_timeout    => "time",
            s                 => "list",
            v                 => "boolean",
        },
    },

    'cat.recovery' => {
        doc   => "cat-recovery",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "recovery", "{index}" ],
            [ {}, "_cat", "recovery" ],
        ],
        qs => {
            active_only => "boolean",
            bytes       => "enum",
            detailed    => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            h           => "list",
            help        => "boolean",
            human       => "boolean",
            s           => "list",
            time        => "enum",
            v           => "boolean",
        },
    },

    'cat.repositories' => {
        doc   => "cat-repositories",
        parts => {},
        paths => [ [ {}, "_cat", "repositories" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            v              => "boolean",
        },
    },

    'cat.segments' => {
        doc   => "cat-segments",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "segments", "{index}" ],
            [ {}, "_cat", "segments" ],
        ],
        qs => {
            bytes       => "enum",
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            h           => "list",
            help        => "boolean",
            human       => "boolean",
            s           => "list",
            v           => "boolean",
        },
    },

    'cat.shards' => {
        doc   => "cat-shards",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "shards", "{index}" ],
            [ {}, "_cat", "shards" ],
        ],
        qs => {
            bytes          => "enum",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            time           => "enum",
            v              => "boolean",
        },
    },

    'cat.snapshots' => {
        doc   => "cat-snapshots",
        parts => { repository => { multi => 1 } },
        paths => [
            [ { repository => 2 }, "_cat", "snapshots", "{repository}" ],
            [ {}, "_cat", "snapshots" ],
        ],
        qs => {
            error_trace        => "boolean",
            filter_path        => "list",
            format             => "string",
            h                  => "list",
            help               => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            s                  => "list",
            time               => "enum",
            v                  => "boolean",
        },
    },

    'cat.tasks' => {
        doc   => "tasks",
        parts => {},
        paths => [ [ {}, "_cat", "tasks" ] ],
        qs    => {
            actions        => "list",
            detailed       => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            nodes          => "list",
            parent_task_id => "string",
            s              => "list",
            time           => "enum",
            v              => "boolean",
        },
    },

    'cat.templates' => {
        doc   => "cat-templates",
        parts => { name => {} },
        paths => [
            [ { name => 2 }, "_cat", "templates", "{name}" ],
            [ {}, "_cat", "templates" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            v              => "boolean",
        },
    },

    'cat.thread_pool' => {
        doc   => "cat-thread-pool",
        parts => { thread_pool_patterns => { multi => 1 } },
        paths => [
            [   { thread_pool_patterns => 2 }, "_cat",
                "thread_pool",                 "{thread_pool_patterns}",
            ],
            [ {}, "_cat", "thread_pool" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            size           => "enum",
            v              => "boolean",
        },
    },

    'cat.transforms' => {
        doc   => "cat-transforms",
        parts => { transform_id => {} },
        paths => [
            [ { transform_id => 2 }, "_cat", "transforms", "{transform_id}" ],
            [ {}, "_cat", "transforms" ],
        ],
        qs => {
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            from           => "int",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            s              => "list",
            size           => "int",
            time           => "enum",
            v              => "boolean",
        },
    },

    'ccr.delete_auto_follow_pattern' => {
        doc    => "ccr-delete-auto-follow-pattern",
        method => "DELETE",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_ccr", "auto_follow", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.follow' => {
        body   => { required => 1 },
        doc    => "ccr-put-follow",
        method => "PUT",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_ccr", "follow" ] ],
        qs     => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            wait_for_active_shards => "string",
        },
    },

    'ccr.follow_info' => {
        doc   => "ccr-get-follow-info",
        parts => { index => { multi => 1 } },
        paths => [ [ { index => 0 }, "{index}", "_ccr", "info" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.follow_stats' => {
        doc   => "ccr-get-follow-stats",
        parts => { index => { multi => 1 } },
        paths => [ [ { index => 0 }, "{index}", "_ccr", "stats" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.forget_follower' => {
        body   => { required => 1 },
        doc    => "ccr-post-forget-follower",
        method => "POST",
        parts  => { index => {} },
        paths => [ [ { index => 0 }, "{index}", "_ccr", "forget_follower" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.get_auto_follow_pattern' => {
        doc   => "ccr-get-auto-follow-pattern",
        parts => { name => {} },
        paths => [
            [ { name => 2 }, "_ccr", "auto_follow", "{name}" ],
            [ {}, "_ccr", "auto_follow" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.pause_auto_follow_pattern' => {
        doc    => "ccr-pause-auto-follow-pattern",
        method => "POST",
        parts  => { name => {} },
        paths  =>
            [ [ { name => 2 }, "_ccr", "auto_follow", "{name}", "pause" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.pause_follow' => {
        doc    => "ccr-post-pause-follow",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_ccr", "pause_follow" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.put_auto_follow_pattern' => {
        body   => { required => 1 },
        doc    => "ccr-put-auto-follow-pattern",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_ccr", "auto_follow", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.resume_auto_follow_pattern' => {
        doc    => "ccr-resume-auto-follow-pattern",
        method => "POST",
        parts  => { name => {} },
        paths  =>
            [ [ { name => 2 }, "_ccr", "auto_follow", "{name}", "resume" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.resume_follow' => {
        body   => {},
        doc    => "ccr-post-resume-follow",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_ccr", "resume_follow" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.stats' => {
        doc   => "ccr-get-stats",
        parts => {},
        paths => [ [ {}, "_ccr", "stats" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.unfollow' => {
        doc    => "ccr-post-unfollow",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_ccr", "unfollow" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'cluster.allocation_explain' => {
        body  => {},
        doc   => "cluster-allocation-explain",
        parts => {},
        paths => [ [ {}, "_cluster", "allocation", "explain" ] ],
        qs    => {
            error_trace           => "boolean",
            filter_path           => "list",
            human                 => "boolean",
            include_disk_info     => "boolean",
            include_yes_decisions => "boolean",
        },
    },

    'cluster.delete_component_template' => {
        doc    => "indices-component-template",
        method => "DELETE",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_component_template", "{name}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'cluster.delete_voting_config_exclusions' => {
        doc    => "voting-config-exclusions",
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_cluster", "voting_config_exclusions" ] ],
        qs     => {
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            wait_for_removal => "boolean",
        },
    },

    'cluster.exists_component_template' => {
        doc    => "indices-component-template",
        method => "HEAD",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_component_template", "{name}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'cluster.get_component_template' => {
        doc   => "indices-component-template",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 1 }, "_component_template", "{name}" ],
            [ {}, "_component_template" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'cluster.get_settings' => {
        doc   => "cluster-get-settings",
        parts => {},
        paths => [ [ {}, "_cluster", "settings" ] ],
        qs    => {
            error_trace      => "boolean",
            filter_path      => "list",
            flat_settings    => "boolean",
            human            => "boolean",
            include_defaults => "boolean",
            master_timeout   => "time",
            timeout          => "time",
        },
    },

    'cluster.health' => {
        doc   => "cluster-health",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cluster", "health", "{index}" ],
            [ {}, "_cluster", "health" ],
        ],
        qs => {
            error_trace                     => "boolean",
            expand_wildcards                => "enum",
            filter_path                     => "list",
            human                           => "boolean",
            level                           => "enum",
            local                           => "boolean",
            master_timeout                  => "time",
            timeout                         => "time",
            wait_for_active_shards          => "string",
            wait_for_events                 => "enum",
            wait_for_no_initializing_shards => "boolean",
            wait_for_no_relocating_shards   => "boolean",
            wait_for_nodes                  => "string",
            wait_for_status                 => "enum",
        },
    },

    'cluster.pending_tasks' => {
        doc   => "cluster-pending",
        parts => {},
        paths => [ [ {}, "_cluster", "pending_tasks" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'cluster.post_voting_config_exclusions' => {
        doc    => "voting-config-exclusions",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_cluster", "voting_config_exclusions" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            node_ids    => "string",
            node_names  => "string",
            timeout     => "time",
        },
    },

    'cluster.put_component_template' => {
        body   => { required => 1 },
        doc    => "indices-component-template",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_component_template", "{name}" ] ],
        qs     => {
            create         => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'cluster.put_settings' => {
        body   => { required => 1 },
        doc    => "cluster-update-settings",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_cluster", "settings" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            flat_settings  => "boolean",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'cluster.remote_info' => {
        doc   => "cluster-remote-info",
        parts => {},
        paths => [ [ {}, "_remote", "info" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'cluster.reroute' => {
        body   => {},
        doc    => "cluster-reroute",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_cluster", "reroute" ] ],
        qs     => {
            dry_run        => "boolean",
            error_trace    => "boolean",
            explain        => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            metric         => "list",
            retry_failed   => "boolean",
            timeout        => "time",
        },
    },

    'cluster.state' => {
        doc   => "cluster-state",
        parts => { index => { multi => 1 }, metric => { multi => 1 } },
        paths => [
            [   { index => 3, metric => 2 }, "_cluster",
                "state",                     "{metric}",
                "{index}",
            ],
            [ { metric => 2 }, "_cluster", "state", "{metric}" ],
            [ {}, "_cluster", "state" ],
        ],
        qs => {
            allow_no_indices          => "boolean",
            error_trace               => "boolean",
            expand_wildcards          => "enum",
            filter_path               => "list",
            flat_settings             => "boolean",
            human                     => "boolean",
            ignore_unavailable        => "boolean",
            local                     => "boolean",
            master_timeout            => "time",
            wait_for_metadata_version => "number",
            wait_for_timeout          => "time",
        },
    },

    'cluster.stats' => {
        doc   => "cluster-stats",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 3 }, "_cluster", "stats", "nodes", "{node_id}" ],
            [ {}, "_cluster", "stats" ],
        ],
        qs => {
            error_trace   => "boolean",
            filter_path   => "list",
            flat_settings => "boolean",
            human         => "boolean",
            timeout       => "time",
        },
    },

    'dangling_indices.delete_dangling_index' => {
        doc    => "modules-gateway-dangling-indices",
        method => "DELETE",
        parts  => { index_uuid => {} },
        paths  => [ [ { index_uuid => 1 }, "_dangling", "{index_uuid}" ] ],
        qs     => {
            accept_data_loss => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            master_timeout   => "time",
            timeout          => "time",
        },
    },

    'dangling_indices.import_dangling_index' => {
        doc    => "modules-gateway-dangling-indices",
        method => "POST",
        parts  => { index_uuid => {} },
        paths  => [ [ { index_uuid => 1 }, "_dangling", "{index_uuid}" ] ],
        qs     => {
            accept_data_loss => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            master_timeout   => "time",
            timeout          => "time",
        },
    },

    'dangling_indices.list_dangling_indices' => {
        doc   => "modules-gateway-dangling-indices",
        parts => {},
        paths => [ [ {}, "_dangling" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'data_frame_transform_deprecated.delete_transform' => {
        doc    => "delete-transform",
        method => "DELETE",
        parts  => { transform_id => {} },
        paths  => [
            [   { transform_id => 2 }, "_data_frame",
                "transforms",          "{transform_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
        },
    },

    'data_frame_transform_deprecated.get_transform' => {
        doc   => "get-transform",
        parts => { transform_id => {} },
        paths => [
            [   { transform_id => 2 }, "_data_frame",
                "transforms",          "{transform_id}",
            ],
            [ {}, "_data_frame", "transforms" ],
        ],
        qs => {
            allow_no_match    => "boolean",
            error_trace       => "boolean",
            exclude_generated => "boolean",
            filter_path       => "list",
            from              => "int",
            human             => "boolean",
            size              => "int",
        },
    },

    'data_frame_transform_deprecated.get_transform_stats' => {
        doc   => "get-transform-stats",
        parts => { transform_id => {} },
        paths => [
            [   { transform_id => 2 }, "_data_frame",
                "transforms",          "{transform_id}",
                "_stats",
            ],
        ],
        qs => {
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            from           => "number",
            human          => "boolean",
            size           => "number",
        },
    },

    'data_frame_transform_deprecated.preview_transform' => {
        body   => { required => 1 },
        doc    => "preview-transform",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_data_frame", "transforms", "_preview" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'data_frame_transform_deprecated.put_transform' => {
        body   => { required => 1 },
        doc    => "put-transform",
        method => "PUT",
        parts  => { transform_id => {} },
        paths  => [
            [   { transform_id => 2 }, "_data_frame",
                "transforms",          "{transform_id}",
            ],
        ],
        qs => {
            defer_validation => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'data_frame_transform_deprecated.start_transform' => {
        doc    => "start-transform",
        method => "POST",
        parts  => { transform_id => {} },
        paths  => [
            [   { transform_id => 2 }, "_data_frame",
                "transforms",          "{transform_id}",
                "_start",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'data_frame_transform_deprecated.stop_transform' => {
        doc    => "stop-transform",
        method => "POST",
        parts  => { transform_id => {} },
        paths  => [
            [   { transform_id => 2 }, "_data_frame",
                "transforms",          "{transform_id}",
                "_stop",
            ],
        ],
        qs => {
            allow_no_match      => "boolean",
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            timeout             => "time",
            wait_for_completion => "boolean",
        },
    },

    'data_frame_transform_deprecated.update_transform' => {
        body   => { required => 1 },
        doc    => "update-transform",
        method => "POST",
        parts  => { transform_id => { required => 1 } },
        paths  => [
            [   { transform_id => 2 }, "_data_frame",
                "transforms",          "{transform_id}",
                "_update",
            ],
        ],
        qs => {
            defer_validation => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'enrich.delete_policy' => {
        doc    => "delete-enrich-policy-api",
        method => "DELETE",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_enrich", "policy", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'enrich.execute_policy' => {
        doc    => "execute-enrich-policy-api",
        method => "PUT",
        parts  => { name => {} },
        paths  =>
            [ [ { name => 2 }, "_enrich", "policy", "{name}", "_execute" ] ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            wait_for_completion => "boolean",
        },
    },

    'enrich.get_policy' => {
        doc   => "get-enrich-policy-api",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 2 }, "_enrich", "policy", "{name}" ],
            [ {}, "_enrich", "policy" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'enrich.put_policy' => {
        body   => { required => 1 },
        doc    => "put-enrich-policy-api",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_enrich", "policy", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'enrich.stats' => {
        doc   => "enrich-stats-api",
        parts => {},
        paths => [ [ {}, "_enrich", "_stats" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'eql.delete' => {
        doc    => "eql-search-api",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_eql", "search", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'eql.get' => {
        doc   => "eql-search-api",
        parts => { id => {} },
        paths => [ [ { id => 2 }, "_eql", "search", "{id}" ] ],
        qs    => {
            error_trace                 => "boolean",
            filter_path                 => "list",
            human                       => "boolean",
            keep_alive                  => "time",
            wait_for_completion_timeout => "time",
        },
    },

    'eql.get_status' => {
        doc   => "eql-search-api",
        parts => { id => {} },
        paths => [ [ { id => 3 }, "_eql", "search", "status", "{id}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'eql.search' => {
        body  => { required => 1 },
        doc   => "eql-search-api",
        parts => { index => {} },
        paths => [ [ { index => 0 }, "{index}", "_eql", "search" ] ],
        qs    => {
            error_trace                 => "boolean",
            filter_path                 => "list",
            human                       => "boolean",
            keep_alive                  => "time",
            keep_on_completion          => "boolean",
            wait_for_completion_timeout => "time",
        },
    },

    'features.get_features' => {
        doc   => "get-features-api",
        parts => {},
        paths => [ [ {}, "_features" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'features.reset_features' => {
        doc    => "modules-snapshots",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_features", "_reset" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'fleet.global_checkpoints' => {
        parts => { index => {} },
        paths =>
            [ [ { index => 0 }, "{index}", "_fleet", "global_checkpoints" ] ],
        qs => {
            checkpoints      => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            timeout          => "time",
            wait_for_advance => "boolean",
            wait_for_index   => "boolean",
        },
    },

    'graph.explore' => {
        body  => {},
        doc   => "graph-explore-api",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_graph",
                "explore",
            ],
            [ { index => 0 }, "{index}", "_graph", "explore" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            routing     => "string",
            timeout     => "time",
        },
    },

    'ilm.delete_lifecycle' => {
        doc    => "ilm-delete-lifecycle",
        method => "DELETE",
        parts  => { policy => {} },
        paths  => [ [ { policy => 2 }, "_ilm", "policy", "{policy}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.explain_lifecycle' => {
        doc   => "ilm-explain-lifecycle",
        parts => { index => {} },
        paths => [ [ { index => 0 }, "{index}", "_ilm", "explain" ] ],
        qs    => {
            error_trace  => "boolean",
            filter_path  => "list",
            human        => "boolean",
            only_errors  => "boolean",
            only_managed => "boolean",
        },
    },

    'ilm.get_lifecycle' => {
        doc   => "ilm-get-lifecycle",
        parts => { policy => {} },
        paths => [
            [ { policy => 2 }, "_ilm", "policy", "{policy}" ],
            [ {}, "_ilm", "policy" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.get_status' => {
        doc   => "ilm-get-status",
        parts => {},
        paths => [ [ {}, "_ilm", "status" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.move_to_step' => {
        body   => {},
        doc    => "ilm-move-to-step",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 2 }, "_ilm", "move", "{index}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.put_lifecycle' => {
        body   => {},
        doc    => "ilm-put-lifecycle",
        method => "PUT",
        parts  => { policy => {} },
        paths  => [ [ { policy => 2 }, "_ilm", "policy", "{policy}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.remove_policy' => {
        doc    => "ilm-remove-policy",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_ilm", "remove" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.retry' => {
        doc    => "ilm-retry-policy",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_ilm", "retry" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.start' => {
        doc    => "ilm-start",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_ilm", "start" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ilm.stop' => {
        doc    => "ilm-stop",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_ilm", "stop" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'indices.add_block' => {
        doc    => "index-modules-blocks",
        method => "PUT",
        parts  => { block => {}, index => { multi => 1 } },
        paths  => [
            [ { block => 2, index => 0 }, "{index}", "_block", "{block}" ]
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            timeout            => "time",
        },
    },

    'indices.analyze' => {
        body  => {},
        doc   => "indices-analyze",
        parts => { index => {} },
        paths =>
            [ [ { index => 0 }, "{index}", "_analyze" ], [ {}, "_analyze" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'indices.clear_cache' => {
        doc    => "indices-clearcache",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_cache", "clear" ],
            [ {}, "_cache", "clear" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            fielddata          => "boolean",
            fields             => "list",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            query              => "boolean",
            request            => "boolean",
        },
    },

    'indices.clone' => {
        body   => {},
        doc    => "indices-clone-index",
        method => "PUT",
        parts  => { index => {}, target => {} },
        paths  => [
            [ { index => 0, target => 2 }, "{index}", "_clone", "{target}" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.close' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_close" ] ],
        qs     => {
            allow_no_indices       => "boolean",
            error_trace            => "boolean",
            expand_wildcards       => "enum",
            filter_path            => "list",
            human                  => "boolean",
            ignore_unavailable     => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.create' => {
        body   => {},
        doc    => "indices-create-index",
        method => "PUT",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}" ] ],
        qs     => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            include_type_name      => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.create_data_stream' => {
        doc    => "data-streams",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_data_stream", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'indices.data_streams_stats' => {
        doc   => "data-streams",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 1 }, "_data_stream", "{name}", "_stats" ],
            [ {}, "_data_stream", "_stats" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'indices.delete' => {
        doc    => "indices-delete-index",
        method => "DELETE",
        parts  => { index => { multi => 1 } },
        paths  => [ [ { index => 0 }, "{index}" ] ],
        qs     => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            timeout            => "time",
        },
    },

    'indices.delete_alias' => {
        doc    => "indices-aliases",
        method => "DELETE",
        parts  => { index => { multi => 1 }, name => { multi => 1 } },
        paths  =>
            [ [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ] ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'indices.delete_data_stream' => {
        doc    => "data-streams",
        method => "DELETE",
        parts  => { name => { multi => 1 } },
        paths  => [ [ { name => 1 }, "_data_stream", "{name}" ] ],
        qs     => {
            error_trace      => "boolean",
            expand_wildcards => "enum",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'indices.delete_index_template' => {
        doc    => "indices-templates",
        method => "DELETE",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_index_template", "{name}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'indices.delete_template' => {
        doc    => "indices-templates",
        method => "DELETE",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'indices.exists' => {
        doc    => "indices-exists",
        method => "HEAD",
        parts  => { index => { multi => 1 } },
        paths  => [ [ { index => 0 }, "{index}" ] ],
        qs     => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            include_defaults   => "boolean",
            local              => "boolean",
        },
    },

    'indices.exists_alias' => {
        doc    => "indices-aliases",
        method => "HEAD",
        parts  => { index => { multi => 1 }, name => { multi => 1 } },
        paths  => [
            [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ],
            [ { name  => 1 }, "_alias", "{name}" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
    },

    'indices.exists_index_template' => {
        doc    => "indices-templates",
        method => "HEAD",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_index_template", "{name}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            flat_settings  => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'indices.exists_template' => {
        doc    => "indices-templates",
        method => "HEAD",
        parts  => { name => { multi => 1 } },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            flat_settings  => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'indices.exists_type' => {
        doc    => "indices-types-exists",
        method => "HEAD",
        parts  => { index => { multi => 1 }, type => { multi => 1 } },
        paths  => [
            [ { index => 0, type => 2 }, "{index}", "_mapping", "{type}" ]
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
    },

    'indices.flush' => {
        doc    => "indices-flush",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  =>
            [ [ { index => 0 }, "{index}", "_flush" ], [ {}, "_flush" ] ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            force              => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            wait_if_ongoing    => "boolean",
        },
    },

    'indices.flush_synced' => {
        doc    => "indices-synced-flush-api",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_flush", "synced" ],
            [ {}, "_flush", "synced" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
        },
    },

    'indices.forcemerge' => {
        doc    => "indices-forcemerge",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_forcemerge" ],
            [ {}, "_forcemerge" ],
        ],
        qs => {
            allow_no_indices     => "boolean",
            error_trace          => "boolean",
            expand_wildcards     => "enum",
            filter_path          => "list",
            flush                => "boolean",
            human                => "boolean",
            ignore_unavailable   => "boolean",
            max_num_segments     => "number",
            only_expunge_deletes => "boolean",
        },
    },

    'indices.freeze' => {
        doc    => "freeze-index-api",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_freeze" ] ],
        qs     => {
            allow_no_indices       => "boolean",
            error_trace            => "boolean",
            expand_wildcards       => "enum",
            filter_path            => "list",
            human                  => "boolean",
            ignore_unavailable     => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.get' => {
        doc   => "indices-get-index",
        parts => { index => { multi => 1 } },
        paths => [ [ { index => 0 }, "{index}" ] ],
        qs    => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            include_defaults   => "boolean",
            include_type_name  => "boolean",
            local              => "boolean",
            master_timeout     => "time",
        },
    },

    'indices.get_alias' => {
        doc   => "indices-aliases",
        parts => { index => { multi => 1 }, name => { multi => 1 } },
        paths => [
            [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ],
            [ { index => 0 }, "{index}", "_alias" ],
            [ { name  => 1 }, "_alias",  "{name}" ],
            [ {}, "_alias" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
    },

    'indices.get_data_stream' => {
        doc   => "data-streams",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 1 }, "_data_stream", "{name}" ],
            [ {}, "_data_stream" ],
        ],
        qs => {
            error_trace      => "boolean",
            expand_wildcards => "enum",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'indices.get_field_mapping' => {
        doc   => "indices-get-field-mapping",
        parts => {
            fields => { multi => 1 },
            index  => { multi => 1 },
            type   => { multi => 1 },
        },
        paths => [
            [   { fields => 4, index => 0, type => 2 }, "{index}",
                "_mapping",                             "{type}",
                "field",                                "{fields}",
            ],
            [   { fields => 3, index => 0 }, "{index}",
                "_mapping",                  "field",
                "{fields}",
            ],
            [   { fields => 3, type => 1 }, "_mapping",
                "{type}",                   "field",
                "{fields}",
            ],
            [ { fields => 2 }, "_mapping", "field", "{fields}" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            include_defaults   => "boolean",
            include_type_name  => "boolean",
            local              => "boolean",
        },
    },

    'indices.get_index_template' => {
        doc   => "indices-templates",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 1 }, "_index_template", "{name}" ],
            [ {}, "_index_template" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            flat_settings  => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'indices.get_mapping' => {
        doc   => "indices-get-mapping",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 2 }, "{index}", "_mapping", "{type}" ],
            [ { index => 0 }, "{index}",  "_mapping" ],
            [ { type  => 1 }, "_mapping", "{type}" ],
            [ {}, "_mapping" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            include_type_name  => "boolean",
            local              => "boolean",
            master_timeout     => "time",
        },
    },

    'indices.get_settings' => {
        doc   => "indices-get-settings",
        parts => { index => { multi => 1 }, name => { multi => 1 } },
        paths => [
            [ { index => 0, name => 2 }, "{index}", "_settings", "{name}" ],
            [ { index => 0 }, "{index}",   "_settings" ],
            [ { name  => 1 }, "_settings", "{name}" ],
            [ {}, "_settings" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            include_defaults   => "boolean",
            local              => "boolean",
            master_timeout     => "time",
        },
    },

    'indices.get_template' => {
        doc   => "indices-templates",
        parts => { name => { multi => 1 } },
        paths =>
            [ [ { name => 1 }, "_template", "{name}" ], [ {}, "_template" ] ],
        qs => {
            error_trace       => "boolean",
            filter_path       => "list",
            flat_settings     => "boolean",
            human             => "boolean",
            include_type_name => "boolean",
            local             => "boolean",
            master_timeout    => "time",
        },
    },

    'indices.get_upgrade' => {
        doc   => "indices-upgrade",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_upgrade" ], [ {}, "_upgrade" ] ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
        },
    },

    'indices.migrate_to_data_stream' => {
        doc    => "data-streams",
        method => "POST",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_data_stream", "_migrate", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'indices.open' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_open" ] ],
        qs     => {
            allow_no_indices       => "boolean",
            error_trace            => "boolean",
            expand_wildcards       => "enum",
            filter_path            => "list",
            human                  => "boolean",
            ignore_unavailable     => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.promote_data_stream' => {
        doc    => "data-streams",
        method => "POST",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_data_stream", "_promote", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'indices.put_alias' => {
        body   => {},
        doc    => "indices-aliases",
        method => "PUT",
        parts  => { index => { multi => 1 }, name => {} },
        paths  =>
            [ [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ] ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'indices.put_index_template' => {
        body   => { required => 1 },
        doc    => "indices-templates",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_index_template", "{name}" ] ],
        qs     => {
            cause          => "string",
            create         => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'indices.put_mapping' => {
        body   => { required => 1 },
        doc    => "indices-put-mapping",
        method => "PUT",
        parts  => { index => { multi => 1 }, type => {} },
        paths  => [
            [ { index => 0, type => 2 }, "{index}", "_mapping", "{type}" ],
            [ { index => 0 }, "{index}",  "_mapping" ],
            [ { type  => 1 }, "_mapping", "{type}" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            include_type_name  => "boolean",
            master_timeout     => "time",
            timeout            => "time",
            write_index_only   => "boolean",
        },
    },

    'indices.put_settings' => {
        body   => { required => 1 },
        doc    => "indices-update-settings",
        method => "PUT",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_settings" ],
            [ {}, "_settings" ]
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            preserve_existing  => "boolean",
            timeout            => "time",
        },
    },

    'indices.put_template' => {
        body   => { required => 1 },
        doc    => "indices-templates",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs     => {
            create            => "boolean",
            error_trace       => "boolean",
            filter_path       => "list",
            human             => "boolean",
            include_type_name => "boolean",
            master_timeout    => "time",
            order             => "number",
        },
    },

    'indices.recovery' => {
        doc   => "indices-recovery",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_recovery" ],
            [ {}, "_recovery" ]
        ],
        qs => {
            active_only => "boolean",
            detailed    => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'indices.refresh' => {
        doc    => "indices-refresh",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  =>
            [ [ { index => 0 }, "{index}", "_refresh" ], [ {}, "_refresh" ] ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
        },
    },

    'indices.reload_search_analyzers' => {
        doc   => "indices-reload-analyzers",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_reload_search_analyzers" ] ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
        },
    },

    'indices.resolve_index' => {
        doc   => "indices-resolve-index-api",
        parts => { name => { multi => 1 } },
        paths => [ [ { name => 2 }, "_resolve", "index", "{name}" ] ],
        qs    => {
            error_trace      => "boolean",
            expand_wildcards => "enum",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'indices.rollover' => {
        body   => {},
        doc    => "indices-rollover-index",
        method => "POST",
        parts  => { alias => {}, new_index => {} },
        paths  => [
            [   { alias => 0, new_index => 2 }, "{alias}",
                "_rollover",                    "{new_index}",
            ],
            [ { alias => 0 }, "{alias}", "_rollover" ],
        ],
        qs => {
            dry_run                => "boolean",
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            include_type_name      => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.segments' => {
        doc   => "indices-segments",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_segments" ],
            [ {}, "_segments" ]
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            verbose            => "boolean",
        },
    },

    'indices.shard_stores' => {
        doc   => "indices-shards-stores",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_shard_stores" ],
            [ {}, "_shard_stores" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            status             => "list",
        },
    },

    'indices.shrink' => {
        body   => {},
        doc    => "indices-shrink-index",
        method => "PUT",
        parts  => { index => {}, target => {} },
        paths  => [
            [ { index => 0, target => 2 }, "{index}", "_shrink", "{target}" ],
        ],
        qs => {
            copy_settings          => "boolean",
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.simulate_index_template' => {
        body   => {},
        doc    => "indices-templates",
        method => "POST",
        parts  => { name => {} },
        paths  => [
            [ { name => 2 }, "_index_template", "_simulate_index", "{name}" ],
        ],
        qs => {
            cause          => "string",
            create         => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'indices.simulate_template' => {
        body   => {},
        doc    => "indices-templates",
        method => "POST",
        parts  => { name => {} },
        paths  => [
            [ { name => 2 }, "_index_template", "_simulate", "{name}" ],
            [ {}, "_index_template", "_simulate" ],
        ],
        qs => {
            cause          => "string",
            create         => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'indices.split' => {
        body   => {},
        doc    => "indices-split-index",
        method => "PUT",
        parts  => { index => {}, target => {} },
        paths  => [
            [ { index => 0, target => 2 }, "{index}", "_split", "{target}" ],
        ],
        qs => {
            copy_settings          => "boolean",
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.stats' => {
        doc   => "indices-stats",
        parts => { index => { multi => 1 }, metric => { multi => 1 } },
        paths => [
            [ { index  => 0, metric => 2 }, "{index}", "_stats", "{metric}" ],
            [ { index  => 0 }, "{index}", "_stats" ],
            [ { metric => 1 }, "_stats",  "{metric}" ],
            [ {}, "_stats" ],
        ],
        qs => {
            completion_fields          => "list",
            error_trace                => "boolean",
            expand_wildcards           => "enum",
            fielddata_fields           => "list",
            fields                     => "list",
            filter_path                => "list",
            forbid_closed_indices      => "boolean",
            groups                     => "list",
            human                      => "boolean",
            include_segment_file_sizes => "boolean",
            include_unloaded_segments  => "boolean",
            level                      => "enum",
            types                      => "list",
        },
    },

    'indices.unfreeze' => {
        doc    => "unfreeze-index-api",
        method => "POST",
        parts  => { index => {} },
        paths  => [ [ { index => 0 }, "{index}", "_unfreeze" ] ],
        qs     => {
            allow_no_indices       => "boolean",
            error_trace            => "boolean",
            expand_wildcards       => "enum",
            filter_path            => "list",
            human                  => "boolean",
            ignore_unavailable     => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
    },

    'indices.update_aliases' => {
        body   => { required => 1 },
        doc    => "indices-aliases",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_aliases" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'indices.upgrade' => {
        doc    => "indices-upgrade",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  =>
            [ [ { index => 0 }, "{index}", "_upgrade" ], [ {}, "_upgrade" ] ],
        qs => {
            allow_no_indices      => "boolean",
            error_trace           => "boolean",
            expand_wildcards      => "enum",
            filter_path           => "list",
            human                 => "boolean",
            ignore_unavailable    => "boolean",
            only_ancient_segments => "boolean",
            wait_for_completion   => "boolean",
        },
    },

    'indices.validate_query' => {
        body  => {},
        doc   => "search-validate",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_validate",
                "query",
            ],
            [ { index => 0 }, "{index}", "_validate", "query" ],
            [ {}, "_validate", "query" ],
        ],
        qs => {
            all_shards         => "boolean",
            allow_no_indices   => "boolean",
            analyze_wildcard   => "boolean",
            analyzer           => "string",
            default_operator   => "enum",
            df                 => "string",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            explain            => "boolean",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            lenient            => "boolean",
            q                  => "string",
            rewrite            => "boolean",
        },
    },

    'ingest.delete_pipeline' => {
        doc    => "delete-pipeline-api",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_ingest", "pipeline", "{id}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'ingest.geo_ip_stats' => {
        doc   => "geoip-stats-api",
        parts => {},
        paths => [ [ {}, "_ingest", "geoip", "stats" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ingest.get_pipeline' => {
        doc   => "get-pipeline-api",
        parts => { id => {} },
        paths => [
            [ { id => 2 }, "_ingest", "pipeline", "{id}" ],
            [ {}, "_ingest", "pipeline" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            summary        => "boolean",
        },
    },

    'ingest.processor_grok' => {
        doc   => "",
        parts => {},
        paths => [ [ {}, "_ingest", "processor", "grok" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ingest.put_pipeline' => {
        body   => { required => 1 },
        doc    => "put-pipeline-api",
        method => "PUT",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_ingest", "pipeline", "{id}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'ingest.simulate' => {
        body  => { required => 1 },
        doc   => "simulate-pipeline-api",
        parts => { id => {} },
        paths => [
            [ { id => 2 }, "_ingest", "pipeline", "{id}", "_simulate" ],
            [ {}, "_ingest", "pipeline", "_simulate" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            verbose     => "boolean",
        },
    },

    'license.delete' => {
        doc    => "delete-license",
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_license" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'license.get' => {
        doc   => "get-license",
        parts => {},
        paths => [ [ {}, "_license" ] ],
        qs    => {
            accept_enterprise => "boolean",
            error_trace       => "boolean",
            filter_path       => "list",
            human             => "boolean",
            local             => "boolean",
        },
    },

    'license.get_basic_status' => {
        doc   => "get-basic-status",
        parts => {},
        paths => [ [ {}, "_license", "basic_status" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'license.get_trial_status' => {
        doc   => "get-trial-status",
        parts => {},
        paths => [ [ {}, "_license", "trial_status" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'license.post' => {
        body   => {},
        doc    => "update-license",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_license" ] ],
        qs     => {
            acknowledge => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'license.post_start_basic' => {
        doc    => "start-basic",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_license", "start_basic" ] ],
        qs     => {
            acknowledge => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'license.post_start_trial' => {
        doc    => "start-trial",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_license", "start_trial" ] ],
        qs     => {
            acknowledge => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            type        => "string",
        },
    },

    'logstash.delete_pipeline' => {
        doc    => "logstash-api-delete-pipeline",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_logstash", "pipeline", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'logstash.get_pipeline' => {
        doc   => "logstash-api-get-pipeline",
        parts => { id => {} },
        paths => [ [ { id => 2 }, "_logstash", "pipeline", "{id}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'logstash.put_pipeline' => {
        body   => { required => 1 },
        doc    => "logstash-api-put-pipeline",
        method => "PUT",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_logstash", "pipeline", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'migration.deprecations' => {
        doc   => "migration-api-deprecation",
        parts => { index => {} },
        paths => [
            [ { index => 0 }, "{index}", "_migration", "deprecations" ],
            [ {}, "_migration", "deprecations" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.close_job' => {
        body   => {},
        doc    => "ml-close-job",
        method => "POST",
        parts  => { job_id => {} },
        paths  => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_close",
            ],
        ],
        qs => {
            allow_no_jobs  => "boolean",
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            force          => "boolean",
            human          => "boolean",
            timeout        => "time",
        },
    },

    'ml.delete_calendar' => {
        doc    => "ml-delete-calendar",
        method => "DELETE",
        parts  => { calendar_id => {} },
        paths  =>
            [ [ { calendar_id => 2 }, "_ml", "calendars", "{calendar_id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.delete_calendar_event' => {
        doc    => "ml-delete-calendar-event",
        method => "DELETE",
        parts  => { calendar_id => {}, event_id => {} },
        paths  => [
            [   { calendar_id => 2, event_id => 4 }, "_ml",
                "calendars",                         "{calendar_id}",
                "events",                            "{event_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.delete_calendar_job' => {
        doc    => "ml-delete-calendar-job",
        method => "DELETE",
        parts  => { calendar_id => {}, job_id => {} },
        paths  => [
            [   { calendar_id => 2, job_id => 4 },
                "_ml", "calendars", "{calendar_id}", "jobs", "{job_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.delete_data_frame_analytics' => {
        doc    => "delete-dfanalytics",
        method => "DELETE",
        parts  => { id => {} },
        paths  =>
            [ [ { id => 3 }, "_ml", "data_frame", "analytics", "{id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'ml.delete_datafeed' => {
        doc    => "ml-delete-datafeed",
        method => "DELETE",
        parts  => { datafeed_id => {} },
        paths  =>
            [ [ { datafeed_id => 2 }, "_ml", "datafeeds", "{datafeed_id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
        },
    },

    'ml.delete_expired_data' => {
        body   => {},
        doc    => "ml-delete-expired-data",
        method => "DELETE",
        parts  => { job_id => {} },
        paths  => [
            [ { job_id => 2 }, "_ml", "_delete_expired_data", "{job_id}" ],
            [ {}, "_ml", "_delete_expired_data" ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            requests_per_second => "number",
            timeout             => "time",
        },
    },

    'ml.delete_filter' => {
        doc    => "ml-delete-filter",
        method => "DELETE",
        parts  => { filter_id => {} },
        paths  => [ [ { filter_id => 2 }, "_ml", "filters", "{filter_id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.delete_forecast' => {
        doc    => "ml-delete-forecast",
        method => "DELETE",
        parts  => { forecast_id => {}, job_id => {} },
        paths  => [
            [   { forecast_id => 4, job_id => 2 }, "_ml",
                "anomaly_detectors",               "{job_id}",
                "_forecast",                       "{forecast_id}",
            ],
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_forecast",
            ],
        ],
        qs => {
            allow_no_forecasts => "boolean",
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
            timeout            => "time",
        },
    },

    'ml.delete_job' => {
        doc    => "ml-delete-job",
        method => "DELETE",
        parts  => { job_id => {} },
        paths  =>
            [ [ { job_id => 2 }, "_ml", "anomaly_detectors", "{job_id}" ] ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            force               => "boolean",
            human               => "boolean",
            wait_for_completion => "boolean",
        },
    },

    'ml.delete_model_snapshot' => {
        doc    => "ml-delete-snapshot",
        method => "DELETE",
        parts  => { job_id => {}, snapshot_id => {} },
        paths  => [
            [   { job_id => 2, snapshot_id => 4 }, "_ml",
                "anomaly_detectors",               "{job_id}",
                "model_snapshots",                 "{snapshot_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.delete_trained_model' => {
        doc    => "delete-trained-models",
        method => "DELETE",
        parts  => { model_id => {} },
        paths  =>
            [ [ { model_id => 2 }, "_ml", "trained_models", "{model_id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.delete_trained_model_alias' => {
        doc    => "delete-trained-models-aliases",
        method => "DELETE",
        parts  => { model_alias => {}, model_id => {} },
        paths  => [
            [   { model_alias => 4, model_id => 2 }, "_ml",
                "trained_models",                    "{model_id}",
                "model_aliases",                     "{model_alias}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.estimate_model_memory' => {
        body   => { required => 1 },
        doc    => "ml-apis",
        method => "POST",
        parts  => {},
        paths  =>
            [ [ {}, "_ml", "anomaly_detectors", "_estimate_model_memory" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.evaluate_data_frame' => {
        body   => { required => 1 },
        doc    => "evaluate-dfanalytics",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_ml", "data_frame", "_evaluate" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.explain_data_frame_analytics' => {
        body  => {},
        doc   => "explain-dfanalytics",
        parts => { id => {} },
        paths => [
            [   { id => 3 }, "_ml", "data_frame", "analytics",
                "{id}",      "_explain"
            ],
            [ {}, "_ml", "data_frame", "analytics", "_explain" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.find_file_structure' => {
        body   => { required => 1 },
        doc    => "find-structure",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_ml", "find_file_structure" ] ],
        qs     => {
            charset               => "string",
            column_names          => "list",
            delimiter             => "string",
            error_trace           => "boolean",
            explain               => "boolean",
            filter_path           => "list",
            format                => "enum",
            grok_pattern          => "string",
            has_header_row        => "boolean",
            human                 => "boolean",
            line_merge_size_limit => "int",
            lines_to_sample       => "int",
            quote                 => "string",
            should_trim_fields    => "boolean",
            timeout               => "time",
            timestamp_field       => "string",
            timestamp_format      => "string",
        },
        serialize => "bulk",
    },

    'ml.flush_job' => {
        body   => {},
        doc    => "ml-flush-job",
        method => "POST",
        parts  => { job_id => {} },
        paths  => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_flush",
            ],
        ],
        qs => {
            advance_time => "string",
            calc_interim => "boolean",
            end          => "string",
            error_trace  => "boolean",
            filter_path  => "list",
            human        => "boolean",
            skip_time    => "string",
            start        => "string",
        },
    },

    'ml.forecast' => {
        doc    => "ml-forecast",
        method => "POST",
        parts  => { job_id => {} },
        paths  => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_forecast",
            ],
        ],
        qs => {
            duration         => "time",
            error_trace      => "boolean",
            expires_in       => "time",
            filter_path      => "list",
            human            => "boolean",
            max_model_memory => "string",
        },
    },

    'ml.get_buckets' => {
        body  => {},
        doc   => "ml-get-bucket",
        parts => { job_id => {}, timestamp => {} },
        paths => [
            [   { job_id => 2, timestamp => 5 }, "_ml",
                "anomaly_detectors",             "{job_id}",
                "results",                       "buckets",
                "{timestamp}",
            ],
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "results",           "buckets",
            ],
        ],
        qs => {
            anomaly_score   => "double",
            desc            => "boolean",
            end             => "string",
            error_trace     => "boolean",
            exclude_interim => "boolean",
            expand          => "boolean",
            filter_path     => "list",
            from            => "int",
            human           => "boolean",
            size            => "int",
            sort            => "string",
            start           => "string",
        },
    },

    'ml.get_calendar_events' => {
        doc   => "ml-get-calendar-event",
        parts => { calendar_id => {} },
        paths => [
            [   { calendar_id => 2 }, "_ml",
                "calendars",          "{calendar_id}",
                "events",
            ],
        ],
        qs => {
            end         => "time",
            error_trace => "boolean",
            filter_path => "list",
            from        => "int",
            human       => "boolean",
            job_id      => "string",
            size        => "int",
            start       => "string",
        },
    },

    'ml.get_calendars' => {
        body  => {},
        doc   => "ml-get-calendar",
        parts => { calendar_id => {} },
        paths => [
            [ { calendar_id => 2 }, "_ml", "calendars", "{calendar_id}" ],
            [ {}, "_ml", "calendars" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            from        => "int",
            human       => "boolean",
            size        => "int",
        },
    },

    'ml.get_categories' => {
        body  => {},
        doc   => "ml-get-category",
        parts => { category_id => {}, job_id => {} },
        paths => [
            [   { category_id => 5, job_id => 2 }, "_ml",
                "anomaly_detectors",               "{job_id}",
                "results",                         "categories",
                "{category_id}",
            ],
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "results",           "categories",
            ],
        ],
        qs => {
            error_trace           => "boolean",
            filter_path           => "list",
            from                  => "int",
            human                 => "boolean",
            partition_field_value => "string",
            size                  => "int",
        },
    },

    'ml.get_data_frame_analytics' => {
        doc   => "get-dfanalytics",
        parts => { id => {} },
        paths => [
            [ { id => 3 }, "_ml", "data_frame", "analytics", "{id}" ],
            [ {}, "_ml", "data_frame", "analytics" ],
        ],
        qs => {
            allow_no_match    => "boolean",
            error_trace       => "boolean",
            exclude_generated => "boolean",
            filter_path       => "list",
            from              => "int",
            human             => "boolean",
            size              => "int",
        },
    },

    'ml.get_data_frame_analytics_stats' => {
        doc   => "get-dfanalytics-stats",
        parts => { id => {} },
        paths => [
            [   { id => 3 }, "_ml", "data_frame", "analytics",
                "{id}",      "_stats"
            ],
            [ {}, "_ml", "data_frame", "analytics", "_stats" ],
        ],
        qs => {
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            from           => "int",
            human          => "boolean",
            size           => "int",
            verbose        => "boolean",
        },
    },

    'ml.get_datafeed_stats' => {
        doc   => "ml-get-datafeed-stats",
        parts => { datafeed_id => {} },
        paths => [
            [   { datafeed_id => 2 }, "_ml",
                "datafeeds",          "{datafeed_id}",
                "_stats",
            ],
            [ {}, "_ml", "datafeeds", "_stats" ],
        ],
        qs => {
            allow_no_datafeeds => "boolean",
            allow_no_match     => "boolean",
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
        },
    },

    'ml.get_datafeeds' => {
        doc   => "ml-get-datafeed",
        parts => { datafeed_id => {} },
        paths => [
            [ { datafeed_id => 2 }, "_ml", "datafeeds", "{datafeed_id}" ],
            [ {}, "_ml", "datafeeds" ],
        ],
        qs => {
            allow_no_datafeeds => "boolean",
            allow_no_match     => "boolean",
            error_trace        => "boolean",
            exclude_generated  => "boolean",
            filter_path        => "list",
            human              => "boolean",
        },
    },

    'ml.get_filters' => {
        doc   => "ml-get-filter",
        parts => { filter_id => {} },
        paths => [
            [ { filter_id => 2 }, "_ml", "filters", "{filter_id}" ],
            [ {}, "_ml", "filters" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            from        => "int",
            human       => "boolean",
            size        => "int",
        },
    },

    'ml.get_influencers' => {
        body  => {},
        doc   => "ml-get-influencer",
        parts => { job_id => {} },
        paths => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "results",           "influencers",
            ],
        ],
        qs => {
            desc             => "boolean",
            end              => "string",
            error_trace      => "boolean",
            exclude_interim  => "boolean",
            filter_path      => "list",
            from             => "int",
            human            => "boolean",
            influencer_score => "double",
            size             => "int",
            sort             => "string",
            start            => "string",
        },
    },

    'ml.get_job_stats' => {
        doc   => "ml-get-job-stats",
        parts => { job_id => {} },
        paths => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_stats",
            ],
            [ {}, "_ml", "anomaly_detectors", "_stats" ],
        ],
        qs => {
            allow_no_jobs  => "boolean",
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
        },
    },

    'ml.get_jobs' => {
        doc   => "ml-get-job",
        parts => { job_id => {} },
        paths => [
            [ { job_id => 2 }, "_ml", "anomaly_detectors", "{job_id}" ],
            [ {}, "_ml", "anomaly_detectors" ],
        ],
        qs => {
            allow_no_jobs     => "boolean",
            allow_no_match    => "boolean",
            error_trace       => "boolean",
            exclude_generated => "boolean",
            filter_path       => "list",
            human             => "boolean",
        },
    },

    'ml.get_model_snapshots' => {
        body  => {},
        doc   => "ml-get-snapshot",
        parts => { job_id => {}, snapshot_id => {} },
        paths => [
            [   { job_id => 2, snapshot_id => 4 }, "_ml",
                "anomaly_detectors",               "{job_id}",
                "model_snapshots",                 "{snapshot_id}",
            ],
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "model_snapshots",
            ],
        ],
        qs => {
            desc        => "boolean",
            end         => "time",
            error_trace => "boolean",
            filter_path => "list",
            from        => "int",
            human       => "boolean",
            size        => "int",
            sort        => "string",
            start       => "time",
        },
    },

    'ml.get_overall_buckets' => {
        body  => {},
        doc   => "ml-get-overall-buckets",
        parts => { job_id => {} },
        paths => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "results",           "overall_buckets",
            ],
        ],
        qs => {
            allow_no_jobs   => "boolean",
            allow_no_match  => "boolean",
            bucket_span     => "string",
            end             => "string",
            error_trace     => "boolean",
            exclude_interim => "boolean",
            filter_path     => "list",
            human           => "boolean",
            overall_score   => "double",
            start           => "string",
            top_n           => "int",
        },
    },

    'ml.get_records' => {
        body  => {},
        doc   => "ml-get-record",
        parts => { job_id => {} },
        paths => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "results",           "records",
            ],
        ],
        qs => {
            desc            => "boolean",
            end             => "string",
            error_trace     => "boolean",
            exclude_interim => "boolean",
            filter_path     => "list",
            from            => "int",
            human           => "boolean",
            record_score    => "double",
            size            => "int",
            sort            => "string",
            start           => "string",
        },
    },

    'ml.get_trained_models' => {
        doc   => "get-trained-models",
        parts => { model_id => {} },
        paths => [
            [ { model_id => 2 }, "_ml", "trained_models", "{model_id}" ],
            [ {}, "_ml", "trained_models" ],
        ],
        qs => {
            allow_no_match           => "boolean",
            decompress_definition    => "boolean",
            error_trace              => "boolean",
            exclude_generated        => "boolean",
            filter_path              => "list",
            from                     => "int",
            human                    => "boolean",
            include                  => "string",
            include_model_definition => "boolean",
            size                     => "int",
            tags                     => "list",
        },
    },

    'ml.get_trained_models_stats' => {
        doc   => "get-trained-models-stats",
        parts => { model_id => {} },
        paths => [
            [   { model_id => 2 }, "_ml",
                "trained_models",  "{model_id}",
                "_stats",
            ],
            [ {}, "_ml", "trained_models", "_stats" ],
        ],
        qs => {
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            from           => "int",
            human          => "boolean",
            size           => "int",
        },
    },

    'ml.info' => {
        doc   => "get-ml-info",
        parts => {},
        paths => [ [ {}, "_ml", "info" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.open_job' => {
        doc    => "ml-open-job",
        method => "POST",
        parts  => { job_id => {} },
        paths  => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_open"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.post_calendar_events' => {
        body   => { required => 1 },
        doc    => "ml-post-calendar-event",
        method => "POST",
        parts  => { calendar_id => {} },
        paths  => [
            [   { calendar_id => 2 }, "_ml",
                "calendars",          "{calendar_id}",
                "events",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.post_data' => {
        body   => { required => 1 },
        doc    => "ml-post-data",
        method => "POST",
        parts  => { job_id => {} },
        paths  => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_data"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            reset_end   => "string",
            reset_start => "string",
        },
        serialize => "bulk",
    },

    'ml.preview_data_frame_analytics' => {
        body  => {},
        doc   => "preview-dfanalytics",
        parts => { id => {} },
        paths => [
            [   { id => 3 }, "_ml", "data_frame", "analytics",
                "{id}",      "_preview"
            ],
            [ {}, "_ml", "data_frame", "analytics", "_preview" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.preview_datafeed' => {
        body  => {},
        doc   => "ml-preview-datafeed",
        parts => { datafeed_id => {} },
        paths => [
            [   { datafeed_id => 2 }, "_ml",
                "datafeeds",          "{datafeed_id}",
                "_preview",
            ],
            [ {}, "_ml", "datafeeds", "_preview" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.put_calendar' => {
        body   => {},
        doc    => "ml-put-calendar",
        method => "PUT",
        parts  => { calendar_id => {} },
        paths  =>
            [ [ { calendar_id => 2 }, "_ml", "calendars", "{calendar_id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.put_calendar_job' => {
        doc    => "ml-put-calendar-job",
        method => "PUT",
        parts  => { calendar_id => {}, job_id => {} },
        paths  => [
            [   { calendar_id => 2, job_id => 4 },
                "_ml", "calendars", "{calendar_id}", "jobs", "{job_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.put_data_frame_analytics' => {
        body   => { required => 1 },
        doc    => "put-dfanalytics",
        method => "PUT",
        parts  => { id => {} },
        paths  =>
            [ [ { id => 3 }, "_ml", "data_frame", "analytics", "{id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.put_datafeed' => {
        body   => { required => 1 },
        doc    => "ml-put-datafeed",
        method => "PUT",
        parts  => { datafeed_id => {} },
        paths  =>
            [ [ { datafeed_id => 2 }, "_ml", "datafeeds", "{datafeed_id}" ] ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_throttled   => "boolean",
            ignore_unavailable => "boolean",
        },
    },

    'ml.put_filter' => {
        body   => { required => 1 },
        doc    => "ml-put-filter",
        method => "PUT",
        parts  => { filter_id => {} },
        paths  => [ [ { filter_id => 2 }, "_ml", "filters", "{filter_id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.put_job' => {
        body   => { required => 1 },
        doc    => "ml-put-job",
        method => "PUT",
        parts  => { job_id => {} },
        paths  =>
            [ [ { job_id => 2 }, "_ml", "anomaly_detectors", "{job_id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.put_trained_model' => {
        body   => { required => 1 },
        doc    => "put-trained-models",
        method => "PUT",
        parts  => { model_id => {} },
        paths  =>
            [ [ { model_id => 2 }, "_ml", "trained_models", "{model_id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.put_trained_model_alias' => {
        doc    => "put-trained-models-aliases",
        method => "PUT",
        parts  => { model_alias => {}, model_id => {} },
        paths  => [
            [   { model_alias => 4, model_id => 2 }, "_ml",
                "trained_models",                    "{model_id}",
                "model_aliases",                     "{model_alias}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            reassign    => "boolean",
        },
    },

    'ml.revert_model_snapshot' => {
        body   => {},
        doc    => "ml-revert-snapshot",
        method => "POST",
        parts  => { job_id => {}, snapshot_id => {} },
        paths  => [
            [   { job_id => 2, snapshot_id => 4 }, "_ml",
                "anomaly_detectors",               "{job_id}",
                "model_snapshots",                 "{snapshot_id}",
                "_revert",
            ],
        ],
        qs => {
            delete_intervening_results => "boolean",
            error_trace                => "boolean",
            filter_path                => "list",
            human                      => "boolean",
        },
    },

    'ml.set_upgrade_mode' => {
        doc    => "ml-set-upgrade-mode",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_ml", "set_upgrade_mode" ] ],
        qs     => {
            enabled     => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'ml.start_data_frame_analytics' => {
        body   => {},
        doc    => "start-dfanalytics",
        method => "POST",
        parts  => { id => {} },
        paths  => [
            [   { id => 3 }, "_ml", "data_frame", "analytics",
                "{id}",      "_start"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'ml.start_datafeed' => {
        body   => {},
        doc    => "ml-start-datafeed",
        method => "POST",
        parts  => { datafeed_id => {} },
        paths  => [
            [   { datafeed_id => 2 }, "_ml",
                "datafeeds",          "{datafeed_id}",
                "_start",
            ],
        ],
        qs => {
            end         => "string",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            start       => "string",
            timeout     => "time",
        },
    },

    'ml.stop_data_frame_analytics' => {
        body   => {},
        doc    => "stop-dfanalytics",
        method => "POST",
        parts  => { id => {} },
        paths  => [
            [   { id => 3 }, "_ml", "data_frame", "analytics", "{id}",
                "_stop"
            ],
        ],
        qs => {
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            force          => "boolean",
            human          => "boolean",
            timeout        => "time",
        },
    },

    'ml.stop_datafeed' => {
        body   => {},
        doc    => "ml-stop-datafeed",
        method => "POST",
        parts  => { datafeed_id => {} },
        paths  => [
            [   { datafeed_id => 2 }, "_ml",
                "datafeeds",          "{datafeed_id}",
                "_stop",
            ],
        ],
        qs => {
            allow_no_datafeeds => "boolean",
            allow_no_match     => "boolean",
            error_trace        => "boolean",
            filter_path        => "list",
            force              => "boolean",
            human              => "boolean",
            timeout            => "time",
        },
    },

    'ml.update_data_frame_analytics' => {
        body   => { required => 1 },
        doc    => "update-dfanalytics",
        method => "POST",
        parts  => { id => {} },
        paths  => [
            [   { id => 3 }, "_ml", "data_frame", "analytics",
                "{id}",      "_update"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.update_datafeed' => {
        body   => { required => 1 },
        doc    => "ml-update-datafeed",
        method => "POST",
        parts  => { datafeed_id => {} },
        paths  => [
            [   { datafeed_id => 2 }, "_ml",
                "datafeeds",          "{datafeed_id}",
                "_update",
            ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_throttled   => "boolean",
            ignore_unavailable => "boolean",
        },
    },

    'ml.update_filter' => {
        body   => { required => 1 },
        doc    => "ml-update-filter",
        method => "POST",
        parts  => { filter_id => {} },
        paths  => [
            [   { filter_id => 2 }, "_ml", "filters", "{filter_id}",
                "_update"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.update_job' => {
        body   => { required => 1 },
        doc    => "ml-update-job",
        method => "POST",
        parts  => { job_id => {} },
        paths  => [
            [   { job_id => 2 },     "_ml",
                "anomaly_detectors", "{job_id}",
                "_update",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.update_model_snapshot' => {
        body   => { required => 1 },
        doc    => "ml-update-snapshot",
        method => "POST",
        parts  => { job_id => {}, snapshot_id => {} },
        paths  => [
            [   { job_id => 2, snapshot_id => 4 }, "_ml",
                "anomaly_detectors",               "{job_id}",
                "model_snapshots",                 "{snapshot_id}",
                "_update",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.upgrade_job_snapshot' => {
        doc    => "ml-upgrade-job-model-snapshot",
        method => "POST",
        parts  => { job_id => {}, snapshot_id => {} },
        paths  => [
            [   { job_id => 2, snapshot_id => 4 }, "_ml",
                "anomaly_detectors",               "{job_id}",
                "model_snapshots",                 "{snapshot_id}",
                "_upgrade",
            ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            timeout             => "time",
            wait_for_completion => "boolean",
        },
    },

    'ml.validate' => {
        body   => { required => 1 },
        doc    => "ml-jobs",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_ml", "anomaly_detectors", "_validate" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ml.validate_detector' => {
        body   => { required => 1 },
        doc    => "ml-jobs",
        method => "POST",
        parts  => {},
        paths  =>
            [ [ {}, "_ml", "anomaly_detectors", "_validate", "detector" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'monitoring.bulk' => {
        body   => { required => 1 },
        doc    => "monitor-elasticsearch-cluster",
        method => "POST",
        parts  => { type => {} },
        paths  => [
            [ { type => 1 }, "_monitoring", "{type}", "bulk" ],
            [ {}, "_monitoring", "bulk" ],
        ],
        qs => {
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
            interval           => "string",
            system_api_version => "string",
            system_id          => "string",
        },
        serialize => "bulk",
    },

    'nodes.hot_threads' => {
        doc   => "cluster-nodes-hot-threads",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 1 }, "_nodes", "{node_id}", "hot_threads" ],
            [ {}, "_nodes", "hot_threads" ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            ignore_idle_threads => "boolean",
            interval            => "time",
            snapshots           => "number",
            threads             => "number",
            timeout             => "time",
            type                => "enum",
        },
    },

    'nodes.info' => {
        doc   => "cluster-nodes-info",
        parts => { metric => { multi => 1 }, node_id => { multi => 1 } },
        paths => [
            [   { metric => 2, node_id => 1 }, "_nodes",
                "{node_id}",                   "{metric}",
            ],
            [ { metric  => 1 }, "_nodes", "{metric}" ],
            [ { node_id => 1 }, "_nodes", "{node_id}" ],
            [ {}, "_nodes" ],
        ],
        qs => {
            error_trace   => "boolean",
            filter_path   => "list",
            flat_settings => "boolean",
            human         => "boolean",
            timeout       => "time",
        },
    },

    'nodes.reload_secure_settings' => {
        body   => {},
        doc    => "",
        method => "POST",
        parts  => { node_id => { multi => 1 } },
        paths  => [
            [   { node_id => 1 }, "_nodes",
                "{node_id}",      "reload_secure_settings",
            ],
            [ {}, "_nodes", "reload_secure_settings" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'nodes.stats' => {
        doc   => "cluster-nodes-stats",
        parts => {
            index_metric => { multi => 1 },
            metric       => { multi => 1 },
            node_id      => { multi => 1 },
        },
        paths => [
            [   { index_metric => 4, metric => 3, node_id => 1 },
                "_nodes", "{node_id}", "stats", "{metric}", "{index_metric}",
            ],
            [   { index_metric => 3, metric => 2 }, "_nodes",
                "stats",                            "{metric}",
                "{index_metric}",
            ],
            [   { metric => 3, node_id => 1 }, "_nodes",
                "{node_id}",                   "stats",
                "{metric}",
            ],
            [ { metric  => 2 }, "_nodes", "stats",     "{metric}" ],
            [ { node_id => 1 }, "_nodes", "{node_id}", "stats" ],
            [ {}, "_nodes", "stats" ],
        ],
        qs => {
            completion_fields          => "list",
            error_trace                => "boolean",
            fielddata_fields           => "list",
            fields                     => "list",
            filter_path                => "list",
            groups                     => "boolean",
            human                      => "boolean",
            include_segment_file_sizes => "boolean",
            include_unloaded_segments  => "boolean",
            level                      => "enum",
            timeout                    => "time",
            types                      => "list",
        },
    },

    'nodes.usage' => {
        doc   => "cluster-nodes-usage",
        parts => { metric => { multi => 1 }, node_id => { multi => 1 } },
        paths => [
            [   { metric => 3, node_id => 1 }, "_nodes",
                "{node_id}",                   "usage",
                "{metric}",
            ],
            [ { metric  => 2 }, "_nodes", "usage",     "{metric}" ],
            [ { node_id => 1 }, "_nodes", "{node_id}", "usage" ],
            [ {}, "_nodes", "usage" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'rollup.delete_job' => {
        doc    => "rollup-delete-job",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_rollup", "job", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'rollup.get_jobs' => {
        doc   => "rollup-get-job",
        parts => { id => {} },
        paths => [
            [ { id => 2 }, "_rollup", "job", "{id}" ],
            [ {}, "_rollup", "job" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'rollup.get_rollup_caps' => {
        doc   => "rollup-get-rollup-caps",
        parts => { id => {} },
        paths => [
            [ { id => 2 }, "_rollup", "data", "{id}" ],
            [ {}, "_rollup", "data" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'rollup.get_rollup_index_caps' => {
        doc   => "rollup-get-rollup-index-caps",
        parts => { index => {} },
        paths => [ [ { index => 0 }, "{index}", "_rollup", "data" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'rollup.put_job' => {
        body   => { required => 1 },
        doc    => "rollup-put-job",
        method => "PUT",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_rollup", "job", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'rollup.rollup' => {
        body   => { required => 1 },
        doc    => "rollup-api",
        method => "POST",
        parts  =>
            { index => { required => 1 }, rollup_index => { required => 1 } },
        paths => [
            [   { index => 0, rollup_index => 2 }, "{index}",
                "_rollup",                         "{rollup_index}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'rollup.rollup_search' => {
        body  => { required => 1 },
        doc   => "rollup-search",
        parts => { index => { multi => 1 }, type => {} },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}",                  "_rollup_search",
            ],
            [ { index => 0 }, "{index}", "_rollup_search" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            rest_total_hits_as_int => "boolean",
            typed_keys             => "boolean",
        },
    },

    'rollup.start_job' => {
        doc    => "rollup-start-job",
        method => "POST",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_rollup", "job", "{id}", "_start" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'rollup.stop_job' => {
        doc    => "rollup-stop-job",
        method => "POST",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_rollup", "job", "{id}", "_stop" ] ],
        qs     => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            timeout             => "time",
            wait_for_completion => "boolean",
        },
    },

    'searchable_snapshots.cache_stats' => {
        doc   => "searchable-snapshots-apis",
        parts => { node_id => { multi => 1 } },
        paths => [
            [   { node_id => 1 }, "_searchable_snapshots",
                "{node_id}",      "cache",
                "stats",
            ],
            [ {}, "_searchable_snapshots", "cache", "stats" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'searchable_snapshots.clear_cache' => {
        doc    => "searchable-snapshots-apis",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [   { index => 0 },          "{index}",
                "_searchable_snapshots", "cache",
                "clear",
            ],
            [ {}, "_searchable_snapshots", "cache", "clear" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            error_trace        => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
        },
    },

    'searchable_snapshots.mount' => {
        body   => { required => 1 },
        doc    => "searchable-snapshots-api-mount-snapshot",
        method => "POST",
        parts  => { repository => {}, snapshot => {} },
        paths  => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}",                     "{snapshot}",
                "_mount",
            ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            master_timeout      => "time",
            storage             => "string",
            wait_for_completion => "boolean",
        },
    },

    'searchable_snapshots.repository_stats' => {
        doc   => "searchable-snapshots-apis",
        parts => { repository => {} },
        paths => [
            [ { repository => 1 }, "_snapshot", "{repository}", "_stats" ]
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'searchable_snapshots.stats' => {
        doc   => "searchable-snapshots-apis",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_searchable_snapshots", "stats" ],
            [ {}, "_searchable_snapshots", "stats" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            level       => "enum",
        },
    },

    'security.authenticate' => {
        doc   => "security-api-authenticate",
        parts => {},
        paths => [ [ {}, "_security", "_authenticate" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.change_password' => {
        body   => { required => 1 },
        doc    => "security-api-change-password",
        method => "PUT",
        parts  => { username => {} },
        paths  => [
            [   { username => 2 }, "_security",
                "user",            "{username}",
                "_password",
            ],
            [ {}, "_security", "user", "_password" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.clear_api_key_cache' => {
        doc    => "security-api-clear-api-key-cache",
        method => "POST",
        parts  => { ids => { multi => 1 } },
        paths  => [
            [ { ids => 2 }, "_security", "api_key", "{ids}", "_clear_cache" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.clear_cached_privileges' => {
        doc    => "security-api-clear-privilege-cache",
        method => "POST",
        parts  => { application => { multi => 1 } },
        paths  => [
            [   { application => 2 }, "_security",
                "privilege",          "{application}",
                "_clear_cache",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.clear_cached_realms' => {
        doc    => "security-api-clear-cache",
        method => "POST",
        parts  => { realms => { multi => 1 } },
        paths  => [
            [   { realms => 2 }, "_security", "realm", "{realms}",
                "_clear_cache",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            usernames   => "list",
        },
    },

    'security.clear_cached_roles' => {
        doc    => "security-api-clear-role-cache",
        method => "POST",
        parts  => { name => { multi => 1 } },
        paths  => [
            [ { name => 2 }, "_security", "role", "{name}", "_clear_cache" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.clear_cached_service_tokens' => {
        doc    => "security-api-clear-service-token-caches",
        method => "POST",
        parts  => { name => { multi => 1 }, namespace => {}, service => {} },
        paths  => [
            [   { name => 6, namespace => 2, service => 3 }, "_security",
                "service",                                   "{namespace}",
                "{service}",                                 "credential",
                "token",                                     "{name}",
                "_clear_cache",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.create_api_key' => {
        body   => { required => 1 },
        doc    => "security-api-create-api-key",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_security", "api_key" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.create_service_token' => {
        doc    => "security-api-create-service-token",
        method => "POST",
        parts  => { name => {}, namespace => {}, service => {} },
        paths  => [
            [   { name => 6, namespace => 2, service => 3 }, "_security",
                "service",                                   "{namespace}",
                "{service}",                                 "credential",
                "token",                                     "{name}",
            ],
            [   { namespace => 2, service => 3 }, "_security",
                "service",                        "{namespace}",
                "{service}",                      "credential",
                "token",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.delete_privileges' => {
        doc    => "security-api-delete-privilege",
        method => "DELETE",
        parts  => { application => {}, name => {} },
        paths  => [
            [   { application => 2, name => 3 }, "_security",
                "privilege",                     "{application}",
                "{name}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.delete_role' => {
        doc    => "security-api-delete-role",
        method => "DELETE",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_security", "role", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.delete_role_mapping' => {
        doc    => "security-api-delete-role-mapping",
        method => "DELETE",
        parts  => { name => {} },
        paths => [ [ { name => 2 }, "_security", "role_mapping", "{name}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.delete_service_token' => {
        doc    => "security-api-delete-service-token",
        method => "DELETE",
        parts  => { name => {}, namespace => {}, service => {} },
        paths  => [
            [   { name => 6, namespace => 2, service => 3 }, "_security",
                "service",                                   "{namespace}",
                "{service}",                                 "credential",
                "token",                                     "{name}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.delete_user' => {
        doc    => "security-api-delete-user",
        method => "DELETE",
        parts  => { username => {} },
        paths => [ [ { username => 2 }, "_security", "user", "{username}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.disable_user' => {
        doc    => "security-api-disable-user",
        method => "PUT",
        parts  => { username => {} },
        paths  => [
            [   { username => 2 }, "_security",
                "user",            "{username}",
                "_disable"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.enable_user' => {
        doc    => "security-api-enable-user",
        method => "PUT",
        parts  => { username => {} },
        paths  => [
            [   { username => 2 }, "_security",
                "user",            "{username}",
                "_enable"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.get_api_key' => {
        doc   => "security-api-get-api-key",
        parts => {},
        paths => [ [ {}, "_security", "api_key" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            id          => "string",
            name        => "string",
            owner       => "boolean",
            realm_name  => "string",
            username    => "string",
        },
    },

    'security.get_builtin_privileges' => {
        doc   => "security-api-get-builtin-privileges",
        parts => {},
        paths => [ [ {}, "_security", "privilege", "_builtin" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_privileges' => {
        doc   => "security-api-get-privileges",
        parts => { application => {}, name => {} },
        paths => [
            [   { application => 2, name => 3 }, "_security",
                "privilege",                     "{application}",
                "{name}",
            ],
            [   { application => 2 }, "_security",
                "privilege",          "{application}"
            ],
            [ {}, "_security", "privilege" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_role' => {
        doc   => "security-api-get-role",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 2 }, "_security", "role", "{name}" ],
            [ {}, "_security", "role" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_role_mapping' => {
        doc   => "security-api-get-role-mapping",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 2 }, "_security", "role_mapping", "{name}" ],
            [ {}, "_security", "role_mapping" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_service_accounts' => {
        doc   => "security-api-get-service-accounts",
        parts => { namespace => {}, service => {} },
        paths => [
            [   { namespace => 2, service => 3 }, "_security",
                "service",                        "{namespace}",
                "{service}",
            ],
            [ { namespace => 2 }, "_security", "service", "{namespace}" ],
            [ {}, "_security", "service" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_service_credentials' => {
        doc   => "security-api-get-service-credentials",
        parts => { namespace => {}, service => {} },
        paths => [
            [   { namespace => 2, service => 3 }, "_security",
                "service",                        "{namespace}",
                "{service}",                      "credential",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_token' => {
        body   => { required => 1 },
        doc    => "security-api-get-token",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_security", "oauth2", "token" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_user' => {
        doc   => "security-api-get-user",
        parts => { username => { multi => 1 } },
        paths => [
            [ { username => 2 }, "_security", "user", "{username}" ],
            [ {}, "_security", "user" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.get_user_privileges' => {
        doc   => "security-api-get-privileges",
        parts => {},
        paths => [ [ {}, "_security", "user", "_privileges" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.grant_api_key' => {
        body   => { required => 1 },
        doc    => "security-api-grant-api-key",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_security", "api_key", "grant" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.has_privileges' => {
        body  => { required => 1 },
        doc   => "security-api-has-privileges",
        parts => { user => {} },
        paths => [
            [   { user => 2 }, "_security",
                "user",        "{user}",
                "_has_privileges"
            ],
            [ {}, "_security", "user", "_has_privileges" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.invalidate_api_key' => {
        body   => { required => 1 },
        doc    => "security-api-invalidate-api-key",
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_security", "api_key" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.invalidate_token' => {
        body   => { required => 1 },
        doc    => "security-api-invalidate-token",
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_security", "oauth2", "token" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'security.put_privileges' => {
        body   => { required => 1 },
        doc    => "security-api-put-privileges",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_security", "privilege" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.put_role' => {
        body   => { required => 1 },
        doc    => "security-api-put-role",
        method => "PUT",
        parts  => { name => {} },
        paths  => [ [ { name => 2 }, "_security", "role", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.put_role_mapping' => {
        body   => { required => 1 },
        doc    => "security-api-put-role-mapping",
        method => "PUT",
        parts  => { name => {} },
        paths => [ [ { name => 2 }, "_security", "role_mapping", "{name}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'security.put_user' => {
        body   => { required => 1 },
        doc    => "security-api-put-user",
        method => "PUT",
        parts  => { username => {} },
        paths => [ [ { username => 2 }, "_security", "user", "{username}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'shutdown.delete_node' => {
        doc    => "",
        method => "DELETE",
        parts  => { node_id => {} },
        paths  => [ [ { node_id => 1 }, "_nodes", "{node_id}", "shutdown" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'shutdown.get_node' => {
        doc   => "",
        parts => { node_id => {} },
        paths => [
            [ { node_id => 1 }, "_nodes", "{node_id}", "shutdown" ],
            [ {}, "_nodes", "shutdown" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'shutdown.put_node' => {
        body   => { required => 1 },
        doc    => "",
        method => "PUT",
        parts  => { node_id => {} },
        paths  => [ [ { node_id => 1 }, "_nodes", "{node_id}", "shutdown" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.delete_lifecycle' => {
        doc    => "slm-api-delete-policy",
        method => "DELETE",
        parts  => { policy_id => {} },
        paths  => [ [ { policy_id => 2 }, "_slm", "policy", "{policy_id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.execute_lifecycle' => {
        doc    => "slm-api-execute-lifecycle",
        method => "PUT",
        parts  => { policy_id => {} },
        paths  => [
            [   { policy_id => 2 }, "_slm",
                "policy",           "{policy_id}",
                "_execute"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.execute_retention' => {
        doc    => "slm-api-execute-retention",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_slm", "_execute_retention" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.get_lifecycle' => {
        doc   => "slm-api-get-policy",
        parts => { policy_id => { multi => 1 } },
        paths => [
            [ { policy_id => 2 }, "_slm", "policy", "{policy_id}" ],
            [ {}, "_slm", "policy" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.get_stats' => {
        doc   => "slm-api-get-stats",
        parts => {},
        paths => [ [ {}, "_slm", "stats" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.get_status' => {
        doc   => "slm-api-get-status",
        parts => {},
        paths => [ [ {}, "_slm", "status" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.put_lifecycle' => {
        body   => {},
        doc    => "slm-api-put-policy",
        method => "PUT",
        parts  => { policy_id => {} },
        paths  => [ [ { policy_id => 2 }, "_slm", "policy", "{policy_id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.start' => {
        doc    => "slm-api-start",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_slm", "start" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'slm.stop' => {
        doc    => "slm-api-stop",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_slm", "stop" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'snapshot.cleanup_repository' => {
        doc    => "clean-up-snapshot-repo-api",
        method => "POST",
        parts  => { repository => {} },
        paths  => [
            [ { repository => 1 }, "_snapshot", "{repository}", "_cleanup" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'snapshot.clone' => {
        body   => { required => 1 },
        doc    => "modules-snapshots",
        method => "PUT",
        parts  => { repository => {}, snapshot => {}, target_snapshot => {} },
        paths  => [
            [   { repository => 1, snapshot => 2, target_snapshot => 4 },
                "_snapshot",
                "{repository}",
                "{snapshot}",
                "_clone",
                "{target_snapshot}",
            ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'snapshot.create' => {
        body   => {},
        doc    => "modules-snapshots",
        method => "PUT",
        parts  => { repository => {}, snapshot => {} },
        paths  => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}",                     "{snapshot}",
            ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            master_timeout      => "time",
            wait_for_completion => "boolean",
        },
    },

    'snapshot.create_repository' => {
        body   => { required => 1 },
        doc    => "modules-snapshots",
        method => "PUT",
        parts  => { repository => {} },
        paths  => [ [ { repository => 1 }, "_snapshot", "{repository}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
            verify         => "boolean",
        },
    },

    'snapshot.delete' => {
        doc    => "modules-snapshots",
        method => "DELETE",
        parts  => { repository => {}, snapshot => {} },
        paths  => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}",                     "{snapshot}",
            ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'snapshot.delete_repository' => {
        doc    => "modules-snapshots",
        method => "DELETE",
        parts  => { repository => { multi => 1 } },
        paths  => [ [ { repository => 1 }, "_snapshot", "{repository}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'snapshot.get' => {
        doc   => "modules-snapshots",
        parts => { repository => {}, snapshot => { multi => 1 } },
        paths => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}",                     "{snapshot}",
            ],
        ],
        qs => {
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            index_details      => "boolean",
            master_timeout     => "time",
            verbose            => "boolean",
        },
    },

    'snapshot.get_repository' => {
        doc   => "modules-snapshots",
        parts => { repository => { multi => 1 } },
        paths => [
            [ { repository => 1 }, "_snapshot", "{repository}" ],
            [ {}, "_snapshot" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'snapshot.repository_analyze' => {
        doc    => "modules-snapshots",
        method => "POST",
        parts  => { repository => {} },
        paths  => [
            [ { repository => 1 }, "_snapshot", "{repository}", "_analyze" ],
        ],
        qs => {
            blob_count              => "number",
            concurrency             => "number",
            detailed                => "boolean",
            early_read_node_count   => "number",
            error_trace             => "boolean",
            filter_path             => "list",
            human                   => "boolean",
            max_blob_size           => "string",
            max_total_data_size     => "string",
            rare_action_probability => "number",
            read_node_count         => "number",
            seed                    => "number",
            timeout                 => "time",
        },
    },

    'snapshot.restore' => {
        body   => {},
        doc    => "modules-snapshots",
        method => "POST",
        parts  => { repository => {}, snapshot => {} },
        paths  => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}",                     "{snapshot}",
                "_restore",
            ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            master_timeout      => "time",
            wait_for_completion => "boolean",
        },
    },

    'snapshot.status' => {
        doc   => "modules-snapshots",
        parts => { repository => {}, snapshot => { multi => 1 } },
        paths => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}",                     "{snapshot}",
                "_status",
            ],
            [ { repository => 1 }, "_snapshot", "{repository}", "_status" ],
            [ {}, "_snapshot", "_status" ],
        ],
        qs => {
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
        },
    },

    'snapshot.verify_repository' => {
        doc    => "modules-snapshots",
        method => "POST",
        parts  => { repository => {} },
        paths  => [
            [ { repository => 1 }, "_snapshot", "{repository}", "_verify" ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'sql.clear_cursor' => {
        body   => { required => 1 },
        doc    => "sql-pagination",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_sql", "close" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'sql.query' => {
        body   => { required => 1 },
        doc    => "sql-rest-overview",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_sql" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            human       => "boolean",
        },
    },

    'sql.translate' => {
        body   => { required => 1 },
        doc    => "sql-translate",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_sql", "translate" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ssl.certificates' => {
        doc   => "security-api-ssl",
        parts => {},
        paths => [ [ {}, "_ssl", "certificates" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'tasks.cancel' => {
        doc    => "tasks",
        method => "POST",
        parts  => { task_id => {} },
        paths  => [
            [ { task_id => 1 }, "_tasks", "{task_id}", "_cancel" ],
            [ {}, "_tasks", "_cancel" ],
        ],
        qs => {
            actions             => "list",
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            nodes               => "list",
            parent_task_id      => "string",
            wait_for_completion => "boolean",
        },
    },

    'tasks.get' => {
        doc   => "tasks",
        parts => { task_id => {} },
        paths => [ [ { task_id => 1 }, "_tasks", "{task_id}" ] ],
        qs    => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            timeout             => "time",
            wait_for_completion => "boolean",
        },
    },

    'tasks.list' => {
        doc   => "tasks",
        parts => {},
        paths => [ [ {}, "_tasks" ] ],
        qs    => {
            actions             => "list",
            detailed            => "boolean",
            error_trace         => "boolean",
            filter_path         => "list",
            group_by            => "enum",
            human               => "boolean",
            nodes               => "list",
            parent_task_id      => "string",
            timeout             => "time",
            wait_for_completion => "boolean",
        },
    },

    'text_structure.find_structure' => {
        body   => { required => 1 },
        doc    => "find-structure",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_text_structure", "find_structure" ] ],
        qs     => {
            charset               => "string",
            column_names          => "list",
            delimiter             => "string",
            error_trace           => "boolean",
            explain               => "boolean",
            filter_path           => "list",
            format                => "enum",
            grok_pattern          => "string",
            has_header_row        => "boolean",
            human                 => "boolean",
            line_merge_size_limit => "int",
            lines_to_sample       => "int",
            quote                 => "string",
            should_trim_fields    => "boolean",
            timeout               => "time",
            timestamp_field       => "string",
            timestamp_format      => "string",
        },
        serialize => "bulk",
    },

    'transform.delete_transform' => {
        doc    => "delete-transform",
        method => "DELETE",
        parts  => { transform_id => {} },
        paths  =>
            [ [ { transform_id => 1 }, "_transform", "{transform_id}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
        },
    },

    'transform.get_transform' => {
        doc   => "get-transform",
        parts => { transform_id => {} },
        paths => [
            [ { transform_id => 1 }, "_transform", "{transform_id}" ],
            [ {}, "_transform" ],
        ],
        qs => {
            allow_no_match    => "boolean",
            error_trace       => "boolean",
            exclude_generated => "boolean",
            filter_path       => "list",
            from              => "int",
            human             => "boolean",
            size              => "int",
        },
    },

    'transform.get_transform_stats' => {
        doc   => "get-transform-stats",
        parts => { transform_id => {} },
        paths => [
            [   { transform_id => 1 }, "_transform",
                "{transform_id}",      "_stats"
            ],
        ],
        qs => {
            allow_no_match => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            from           => "number",
            human          => "boolean",
            size           => "number",
        },
    },

    'transform.preview_transform' => {
        body   => { required => 1 },
        doc    => "preview-transform",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_transform", "_preview" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'transform.put_transform' => {
        body   => { required => 1 },
        doc    => "put-transform",
        method => "PUT",
        parts  => { transform_id => {} },
        paths  =>
            [ [ { transform_id => 1 }, "_transform", "{transform_id}" ] ],
        qs => {
            defer_validation => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'transform.start_transform' => {
        doc    => "start-transform",
        method => "POST",
        parts  => { transform_id => {} },
        paths  => [
            [   { transform_id => 1 }, "_transform",
                "{transform_id}",      "_start"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'transform.stop_transform' => {
        doc    => "stop-transform",
        method => "POST",
        parts  => { transform_id => {} },
        paths  => [
            [   { transform_id => 1 }, "_transform", "{transform_id}",
                "_stop"
            ],
        ],
        qs => {
            allow_no_match      => "boolean",
            error_trace         => "boolean",
            filter_path         => "list",
            force               => "boolean",
            human               => "boolean",
            timeout             => "time",
            wait_for_checkpoint => "boolean",
            wait_for_completion => "boolean",
        },
    },

    'transform.update_transform' => {
        body   => { required => 1 },
        doc    => "update-transform",
        method => "POST",
        parts  => { transform_id => { required => 1 } },
        paths  => [
            [   { transform_id => 1 }, "_transform",
                "{transform_id}",      "_update",
            ],
        ],
        qs => {
            defer_validation => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'watcher.ack_watch' => {
        doc    => "watcher-api-ack-watch",
        method => "PUT",
        parts  => { action_id => { multi => 1 }, watch_id => {} },
        paths  => [
            [   { action_id => 4, watch_id => 2 }, "_watcher",
                "watch",                           "{watch_id}",
                "_ack",                            "{action_id}",
            ],
            [ { watch_id => 2 }, "_watcher", "watch", "{watch_id}", "_ack" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'watcher.activate_watch' => {
        doc    => "watcher-api-activate-watch",
        method => "PUT",
        parts  => { watch_id => {} },
        paths  => [
            [   { watch_id => 2 }, "_watcher",
                "watch",           "{watch_id}",
                "_activate",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'watcher.deactivate_watch' => {
        doc    => "watcher-api-deactivate-watch",
        method => "PUT",
        parts  => { watch_id => {} },
        paths  => [
            [   { watch_id => 2 }, "_watcher",
                "watch",           "{watch_id}",
                "_deactivate",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'watcher.delete_watch' => {
        doc    => "watcher-api-delete-watch",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'watcher.execute_watch' => {
        body   => {},
        doc    => "watcher-api-execute-watch",
        method => "PUT",
        parts  => { id => {} },
        paths  => [
            [ { id => 2 }, "_watcher", "watch", "{id}", "_execute" ],
            [ {}, "_watcher", "watch", "_execute" ],
        ],
        qs => {
            debug       => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'watcher.get_watch' => {
        doc   => "watcher-api-get-watch",
        parts => { id => {} },
        paths => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'watcher.put_watch' => {
        body   => {},
        doc    => "watcher-api-put-watch",
        method => "PUT",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs     => {
            active          => "boolean",
            error_trace     => "boolean",
            filter_path     => "list",
            human           => "boolean",
            if_primary_term => "number",
            if_seq_no       => "number",
            version         => "number",
        },
    },

    'watcher.query_watches' => {
        body  => {},
        doc   => "watcher-api-query-watches",
        parts => {},
        paths => [ [ {}, "_watcher", "_query", "watches" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'watcher.start' => {
        doc    => "watcher-api-start",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_start" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'watcher.stats' => {
        doc   => "watcher-api-stats",
        parts => { metric => { multi => 1 } },
        paths => [
            [ { metric => 2 }, "_watcher", "stats", "{metric}" ],
            [ {}, "_watcher", "stats" ],
        ],
        qs => {
            emit_stacktraces => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'watcher.stop' => {
        doc    => "watcher-api-stop",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_stop" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.info' => {
        doc   => "info-api",
        parts => {},
        paths => [ [ {}, "_xpack" ] ],
        qs    => {
            accept_enterprise => "boolean",
            categories        => "list",
            error_trace       => "boolean",
            filter_path       => "list",
            human             => "boolean",
        },
    },

    'xpack.usage' => {
        doc   => "usage-api",
        parts => {},
        paths => [ [ {}, "_xpack", "usage" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

#=== AUTOGEN - END ===

);

__PACKAGE__->_qs_init( \%API );
1;

__END__

# ABSTRACT: This class contains the spec for the Elasticsearch APIs

=head1 DESCRIPTION

All of the Elasticsearch APIs are defined in this role. The example given below
is the definition for the L<Search::Elasticsearch::Client::7_0::Direct/index()> method:

    'index' => {
        body   => { required => 1 },
        doc    => "docs-index_",
        method => "POST",
        parts  => { id => {}, index => {}, type => {} },
        paths  => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",                           "{id}"
            ],
            [ { id    => 2, index => 0 }, "{index}", "_doc", "{id}" ],
            [ { index => 0, type  => 1 }, "{index}", "{type}" ],
            [ { index => 0 }, "{index}", "_doc" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            if_primary_term        => "number",
            if_seq_no              => "number",
            op_type                => "enum",
            pipeline               => "string",
            refresh                => "enum",
            require_alias          => "boolean",
            routing                => "string",
            timeout                => "time",
            version                => "number",
            version_type           => "enum",
            wait_for_active_shards => "string",
        },
    }

These definitions can be used by different L<Search::Elasticsearch::Role::Client>
implementations to provide distinct user interfaces.

=head1 METHODS

=head2 C<api()>

    $defn = $api->api($name);

The only method in this class is the C<api()> method which takes the name
of the I<action> and returns its definition.  Actions in the
C<indices> or C<cluster> namespace use the namespace as a prefix, eg:

    $defn = $e->api('indices.create');
    $defn = $e->api('cluster.node_stats');

=head1 SEE ALSO

=over

=item *

L<Search::Elasticsearch::Role::API>

=item *

L<Search::Elasticsearch::Client::7_0::Direct>

=back
