package Search::Elasticsearch::Client::6_0::Role::API;

use Moo::Role;
with 'Search::Elasticsearch::Role::API';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

has 'api_version' => ( is => 'ro', default => '6_0' );

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
            '_index'        => '_index',
            'index'         => '_index',
            '_type'         => '_type',
            'type'          => '_type',
            '_id'           => '_id',
            'id'            => '_id',
            'pipeline'      => 'pipeline',
            'routing'       => 'routing',
            '_routing'      => 'routing',
            'parent'        => 'parent',
            '_parent'       => 'parent',
            'timestamp'     => 'timestamp',
            '_timestamp'    => 'timestamp',
            'ttl'           => 'ttl',
            '_ttl'          => 'ttl',
            'version'       => 'version',
            '_version'      => 'version',
            'version_type'  => 'version_type',
            '_version_type' => 'version_type'
        }
    },
    'bulk.update' => {
        params => [
            '_source',          '_source_includes',
            '_source_excludes', 'detect_noop',
            'doc',              'doc_as_upsert',
            'fields',           'retry_on_conflict',
            'scripted_upsert',  'script',
            'upsert',
        ]
    },
    'bulk.required' => { params => [ 'index', 'type' ] },

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
            fields                 => "list",
            filter_path            => "list",
            human                  => "boolean",
            pipeline               => "string",
            refresh                => "enum",
            routing                => "string",
            timeout                => "time",
            wait_for_active_shards => "string",
        },
        serialize => "bulk",
    },

    'clear_scroll' => {
        body   => {},
        doc    => "search-request-scroll",
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
        parts  => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_create",
            ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            parent                 => "string",
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
        parts  => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}"
            ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            if_primary_term        => "number",
            if_seq_no              => "number",
            parent                 => "string",
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
                "{type}", "_delete_by_query",
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
            slices                 => "number",
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
        parts  => { task_id => { required => 1 } },
        paths  => [
            [   { task_id => 1 }, "_delete_by_query",
                "{task_id}", "_rethrottle",
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
        parts  => { id => { required => 1 } },
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
        parts  => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}"
            ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            parent           => "string",
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
        parts  => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_source",
            ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            parent           => "string",
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
        parts => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}",
                "_explain",
            ],
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
            parent           => "string",
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
        },
    },

    'get' => {
        doc   => "docs-get",
        parts => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}"
            ],
        ],
        qs => {
            _source          => "list",
            _source_exclude  => "list",
            _source_excludes => "list",
            _source_include  => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            parent           => "string",
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
        parts => { id => { required => 1 } },
        paths => [ [ { id => 1 }, "_scripts", "{id}" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'get_source' => {
        doc   => "docs-get",
        parts => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_source",
            ],
        ],
        qs => {
            _source          => "list",
            _source_excludes => "list",
            _source_includes => "list",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
            parent           => "string",
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
        parts  => {
            id    => {},
            index => { required => 1 },
            type  => { required => 1 }
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}"
            ],
            [ { index => 0, type => 1 }, "{index}", "{type}" ],
        ],
        qs => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            if_primary_term        => "number",
            if_seq_no              => "number",
            op_type                => "enum",
            parent                 => "string",
            pipeline               => "string",
            refresh                => "enum",
            routing                => "string",
            timeout                => "time",
            version                => "number",
            version_type           => "enum",
            wait_for_active_shards => "string",
        },
    },

    'info' => {
        doc   => "",
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
                "{type}", "_msearch",
                "template",
            ],
            [ { index => 0 }, "{index}", "_msearch", "template" ],
            [ {}, "_msearch", "template" ],
        ],
        qs => {
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
                "{type}", "_mtermvectors"
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
            parent           => "string",
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

    'ping' => {
        doc    => "",
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
        parts  => { context => {}, id => { required => 1 } },
        paths  => [
            [ { context => 2, id => 1 }, "_scripts", "{id}", "{context}" ],
            [ { id      => 1 }, "_scripts", "{id}" ],
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
            refresh                => "boolean",
            requests_per_second    => "number",
            slices                 => "number",
            timeout                => "time",
            wait_for_active_shards => "string",
            wait_for_completion    => "boolean",
        },
    },

    'reindex_rethrottle' => {
        doc    => "docs-reindex",
        method => "POST",
        parts  => { task_id => { required => 1 } },
        paths =>
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
        doc   => "search-template",
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
        doc   => "search-request-scroll",
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
                "{type}", "_search",
                "template",
            ],
            [ { index => 0 }, "{index}", "_search", "template" ],
            [ {}, "_search", "template" ],
        ],
        qs => {
            allow_no_indices       => "boolean",
            error_trace            => "boolean",
            expand_wildcards       => "enum",
            explain                => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            ignore_throttled       => "boolean",
            ignore_unavailable     => "boolean",
            preference             => "string",
            profile                => "boolean",
            rest_total_hits_as_int => "boolean",
            routing                => "list",
            scroll                 => "time",
            search_type            => "enum",
            typed_keys             => "boolean",
        },
    },

    'termvectors' => {
        body  => {},
        doc   => "docs-termvectors",
        parts => {
            id    => {},
            index => { required => 1 },
            type  => { required => 1 }
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}",
                "_termvectors",
            ],
            [   { index => 0, type => 1 }, "{index}", "{type}",
                "_termvectors"
            ],
        ],
        qs => {
            error_trace      => "boolean",
            field_statistics => "boolean",
            fields           => "list",
            filter_path      => "list",
            human            => "boolean",
            offsets          => "boolean",
            parent           => "string",
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
        parts  => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_update",
            ],
        ],
        qs => {
            _source                => "list",
            _source_excludes       => "list",
            _source_includes       => "list",
            error_trace            => "boolean",
            fields                 => "list",
            filter_path            => "list",
            human                  => "boolean",
            if_primary_term        => "number",
            if_seq_no              => "number",
            lang                   => "string",
            parent                 => "string",
            refresh                => "enum",
            retry_on_conflict      => "number",
            routing                => "string",
            timeout                => "time",
            version                => "number",
            version_type           => "enum",
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
                "{type}", "_update_by_query",
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
            slices                 => "number",
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
        parts  => { task_id => { required => 1 } },
        paths  => [
            [   { task_id => 1 }, "_update_by_query",
                "{task_id}", "_rethrottle",
            ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            requests_per_second => "number",
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

    'cat.fielddata' => {
        doc   => "cat-fielddata",
        parts => { fields => { multi => 1 } },
        paths => [
            [ { fields => 2 }, "_cat", "fielddata", "{fields}" ],
            [ {}, "_cat", "fielddata" ],
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

    'cat.health' => {
        doc   => "cat-health",
        parts => {},
        paths => [ [ {}, "_cat", "health" ] ],
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
            ts             => "boolean",
            v              => "boolean",
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
            bytes          => "enum",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            health         => "enum",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            pri            => "boolean",
            s              => "list",
            v              => "boolean",
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
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            full_id        => "boolean",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            local          => "boolean",
            master_timeout => "time",
            s              => "list",
            v              => "boolean",
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
            v              => "boolean",
        },
    },

    'cat.plugins' => {
        doc   => "cat-plugins",
        parts => {},
        paths => [ [ {}, "_cat", "plugins" ] ],
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

    'cat.recovery' => {
        doc   => "cat-recovery",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "recovery", "{index}" ],
            [ {}, "_cat", "recovery" ],
        ],
        qs => {
            bytes          => "enum",
            error_trace    => "boolean",
            filter_path    => "list",
            format         => "string",
            h              => "list",
            help           => "boolean",
            human          => "boolean",
            master_timeout => "time",
            s              => "list",
            v              => "boolean",
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
            v                  => "boolean",
        },
    },

    'cat.tasks' => {
        doc   => "tasks",
        parts => {},
        paths => [ [ {}, "_cat", "tasks" ] ],
        qs    => {
            actions     => "list",
            detailed    => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            h           => "list",
            help        => "boolean",
            human       => "boolean",
            node_id     => "list",
            parent_task => "number",
            s           => "list",
            v           => "boolean",
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
                "thread_pool", "{thread_pool_patterns}",
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

    'cluster.get_settings' => {
        doc   => "cluster-update-settings",
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
                "state", "{metric}",
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
            request_cache      => "boolean",
        },
    },

    'indices.close' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { multi => 1, required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_close" ] ],
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

    'indices.create' => {
        body   => {},
        doc    => "indices-create-index",
        method => "PUT",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}" ] ],
        qs     => {
            error_trace            => "boolean",
            filter_path            => "list",
            human                  => "boolean",
            include_type_name      => "boolean",
            master_timeout         => "time",
            timeout                => "time",
            update_all_types       => "boolean",
            wait_for_active_shards => "string",
        },
    },

    'indices.delete' => {
        doc    => "indices-delete-index",
        method => "DELETE",
        parts  => { index => { multi => 1, required => 1 } },
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
        parts  => {
            index => { multi => 1, required => 1 },
            name  => { multi => 1, required => 1 },
        },
        paths =>
            [ [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ] ],
        qs => {
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
        parts  => { name => { required => 1 } },
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
        parts  => { index => { multi => 1, required => 1 } },
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
        parts  => {
            index => { multi => 1 },
            name  => { multi => 1, required => 1 }
        },
        paths => [
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

    'indices.exists_template' => {
        doc    => "indices-templates",
        method => "HEAD",
        parts  => { name => { multi => 1, required => 1 } },
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
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1, required => 1 },
        },
        paths => [
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
        paths =>
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
        doc    => "indices-synced-flush",
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

    'indices.get' => {
        doc   => "indices-get-index",
        parts => { index => { multi => 1, required => 1 } },
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
            [ { name => 1 }, "_alias", "{name}" ],
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

    'indices.get_field_mapping' => {
        doc   => "indices-get-field-mapping",
        parts => {
            fields => { multi => 1, required => 1 },
            index  => { multi => 1 },
            type   => { multi => 1 },
        },
        paths => [
            [   { fields => 4, index => 0, type => 2 }, "{index}",
                "_mapping", "{type}",
                "field",    "{fields}",
            ],
            [   { fields => 3, index => 0 }, "{index}",
                "_mapping", "field",
                "{fields}",
            ],
            [   { fields => 3, type => 1 }, "_mapping",
                "{type}", "field",
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

    'indices.get_mapping' => {
        doc   => "indices-get-mapping",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 2 }, "{index}", "_mapping", "{type}" ],
            [ { index => 0 }, "{index}", "_mapping" ],
            [ { type => 1 }, "_mapping", "{type}" ],
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
            [ { index => 0 }, "{index}", "_settings" ],
            [ { name => 1 }, "_settings", "{name}" ],
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

    'indices.open' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { multi => 1, required => 1 } },
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

    'indices.put_alias' => {
        body   => {},
        doc    => "indices-aliases",
        method => "PUT",
        parts  => {
            index => { multi    => 1, required => 1 },
            name  => { required => 1 }
        },
        paths =>
            [ [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ] ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
        },
    },

    'indices.put_mapping' => {
        body   => { required => 1 },
        doc    => "indices-put-mapping",
        method => "PUT",
        parts  => { index => { multi => 1 }, type => {} },
        paths  => [
            [ { index => 0, type => 2 }, "{index}", "_mapping", "{type}" ],
            [ { index => 0 }, "{index}", "_mapping" ],
            [ { type => 1 }, "_mapping", "{type}" ],
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
            update_all_types   => "boolean",
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
        parts  => { name => { required => 1 } },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs     => {
            create            => "boolean",
            error_trace       => "boolean",
            filter_path       => "list",
            flat_settings     => "boolean",
            human             => "boolean",
            include_type_name => "boolean",
            master_timeout    => "time",
            order             => "number",
            timeout           => "time",
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
        paths =>
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

    'indices.rollover' => {
        body   => {},
        doc    => "indices-rollover-index",
        method => "POST",
        parts  => { alias => { required => 1 }, new_index => {} },
        paths  => [
            [   { alias => 0, new_index => 2 }, "{alias}",
                "_rollover", "{new_index}",
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
        parts  => { index => { required => 1 }, target => { required => 1 } },
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

    'indices.split' => {
        body   => {},
        doc    => "indices-split-index",
        method => "PUT",
        parts  => { index => { required => 1 }, target => { required => 1 } },
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
            [ { index => 0, metric => 2 }, "{index}", "_stats", "{metric}" ],
            [ { index => 0 }, "{index}", "_stats" ],
            [ { metric => 1 }, "_stats", "{metric}" ],
            [ {}, "_stats" ],
        ],
        qs => {
            completion_fields          => "list",
            error_trace                => "boolean",
            fielddata_fields           => "list",
            fields                     => "list",
            filter_path                => "list",
            groups                     => "list",
            human                      => "boolean",
            include_segment_file_sizes => "boolean",
            level                      => "enum",
            types                      => "list",
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
        paths =>
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
                "{type}", "_validate",
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
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 2 }, "_ingest", "pipeline", "{id}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
            timeout        => "time",
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
        parts  => { id => { required => 1 } },
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
                "{node_id}", "{metric}",
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
        doc    => "",
        method => "POST",
        parts  => { node_id => { multi => 1 } },
        paths  => [
            [   { node_id => 1 }, "_nodes",
                "{node_id}", "reload_secure_settings",
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
                "stats", "{metric}",
                "{index_metric}",
            ],
            [   { metric => 3, node_id => 1 }, "_nodes",
                "{node_id}", "stats",
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
                "{node_id}", "usage",
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

    'snapshot.create' => {
        body   => {},
        doc    => "modules-snapshots",
        method => "PUT",
        parts  => {
            repository => { required => 1 },
            snapshot   => { required => 1 }
        },
        paths => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}", "{snapshot}",
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
        parts  => { repository => { required => 1 } },
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
        parts  => {
            repository => { required => 1 },
            snapshot   => { required => 1 }
        },
        paths => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}", "{snapshot}",
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
        parts  => { repository => { multi => 1, required => 1 } },
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
        parts => {
            repository => { required => 1 },
            snapshot   => { multi    => 1, required => 1 },
        },
        paths => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}", "{snapshot}",
            ],
        ],
        qs => {
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
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

    'snapshot.restore' => {
        body   => {},
        doc    => "modules-snapshots",
        method => "POST",
        parts  => {
            repository => { required => 1 },
            snapshot   => { required => 1 }
        },
        paths => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}", "{snapshot}",
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
                "{repository}", "{snapshot}",
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
        parts  => { repository => { required => 1 } },
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

    'tasks.cancel' => {
        doc    => "tasks",
        method => "POST",
        parts  => { task_id => {} },
        paths  => [
            [ { task_id => 1 }, "_tasks", "{task_id}", "_cancel" ],
            [ {}, "_tasks", "_cancel" ],
        ],
        qs => {
            actions        => "list",
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            nodes          => "list",
            parent_task_id => "string",
        },
    },

    'tasks.get' => {
        doc   => "tasks",
        parts => { task_id => { required => 1 } },
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

#=== AUTOGEN - END ===

);

__PACKAGE__->_qs_init( \%API );
1;

__END__

# ABSTRACT: This class contains the spec for the Elasticsearch APIs

=head1 DESCRIPTION

All of the Elasticsearch APIs are defined in this role. The example given below
is the definition for the L<Search::Elasticsearch::Client::6_0::Direct/index()> method:

    'index' => {
        body   => { required => 1 },
        doc    => "docs-index_",
        method => "POST",
        parts  => {
            id    => {},
            index => { required => 1 },
            type  => { required => 1 }
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}"
            ],
            [ { index => 0, type => 1 }, "{index}", "{type}" ],
        ],
        qs => {
            filter_path            => "list",
            op_type                => "enum",
            parent                 => "string",
            pipeline               => "string",
            refresh                => "enum",
            routing                => "string",
            timeout                => "time",
            timestamp              => "time",
            ttl                    => "time",
            version                => "number",
            version_type           => "enum",
            wait_for_active_shards => "string",
        },
    },

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

L<Search::Elasticsearch::Client::6_0::Direct>

=back
