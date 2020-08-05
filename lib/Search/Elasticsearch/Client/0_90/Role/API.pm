# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Client::0_90::Role::API;

use Moo::Role;
with 'Search::Elasticsearch::Role::API';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

has 'api_version' => ( is => 'ro', default => '0_90' );

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
        params => [
            'index',   'type',   'id',        'fields',
            'routing', 'parent', 'timestamp', 'ttl',
            'version', 'version_type'
        ]
    },
    'bulk.update' => {
        params => [
            'doc',             'upsert',
            'doc_as_upsert',   'fields',
            'scripted_upsert', 'script',
            'script_id',       'script_file',
            'params',          'lang',
            'detect_noop',
        ]
    },
    'bulk.required' => { params => [ 'index', 'type' ] },

#=== AUTOGEN - START ===

    'bulk' => {
        body   => { required => 1 },
        doc    => "docs-bulk",
        method => "POST",
        parts => { index => {}, type => {} },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_bulk" ],
            [ { index => 0 }, "{index}", "_bulk" ],
            [ {}, "_bulk" ],
        ],
        qs => {
            consistency => "enum",
            filter_path => "list",
            refresh     => "boolean",
            replication => "enum",
            timeout     => "time",
        },
        serialize => "bulk",
    },

    'clear_scroll' => {
        doc    => "search-request-scroll",
        method => "DELETE",
        parts  => { scroll_id => { multi => 1 } },
        paths =>
            [ [ { scroll_id => 2 }, "_search", "scroll", "{scroll_id}" ] ],
        qs => { filter_path => "list" },
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
            filter_path    => "list",
            ignore_indices => "enum",
            min_score      => "number",
            preference     => "string",
            routing        => "string",
            source         => "string",
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
            consistency  => "enum",
            filter_path  => "list",
            parent       => "string",
            refresh      => "boolean",
            replication  => "enum",
            routing      => "string",
            timeout      => "time",
            version      => "number",
            version_type => "enum",
        },
    },

    'delete_by_query' => {
        body   => {},
        doc    => "docs-delete-by-query",
        method => "DELETE",
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1 }
        },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_query" ],
            [ { index => 0 }, "{index}", "_query" ],
        ],
        qs => {
            analyzer         => "string",
            consistency      => "enum",
            default_operator => "enum",
            df               => "string",
            filter_path      => "list",
            ignore_indices   => "enum",
            q                => "string",
            replication      => "enum",
            routing          => "string",
            source           => "string",
            timeout          => "time",
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
            parent     => "string",
            preference => "string",
            realtime   => "boolean",
            refresh    => "boolean",
            routing    => "string",
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
            _source                  => "list",
            _source_exclude          => "list",
            _source_include          => "list",
            analyze_wildcard         => "boolean",
            analyzer                 => "string",
            default_operator         => "enum",
            df                       => "string",
            fields                   => "list",
            filter_path              => "list",
            lenient                  => "boolean",
            lowercase_expanded_terms => "boolean",
            parent                   => "string",
            preference               => "string",
            q                        => "string",
            routing                  => "string",
            source                   => "string",
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
            _source         => "list",
            _source_exclude => "list",
            _source_include => "list",
            fields          => "list",
            filter_path     => "list",
            parent          => "string",
            preference      => "string",
            realtime        => "boolean",
            refresh         => "boolean",
            routing         => "string",
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
            _source         => "list",
            _source_exclude => "list",
            _source_include => "list",
            filter_path     => "list",
            parent          => "string",
            preference      => "string",
            realtime        => "boolean",
            refresh         => "boolean",
            routing         => "string",
            version         => "number",
            version_type    => "enum",
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
            consistency  => "enum",
            filter_path  => "list",
            op_type      => "enum",
            parent       => "string",
            percolate    => "string",
            refresh      => "boolean",
            replication  => "enum",
            routing      => "string",
            timeout      => "time",
            timestamp    => "time",
            ttl          => "time",
            version      => "number",
            version_type => "enum",
        },
    },

    'info' => {
        doc   => "",
        parts => {},
        paths => [ [ {} ] ],
        qs    => { filter_path => "list" }
    },

    'mget' => {
        body => { required => 1 },
        doc  => "docs-multi-get",
        parts => { index => {}, type => {} },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mget" ],
            [ { index => 0 }, "{index}", "_mget" ],
            [ {}, "_mget" ],
        ],
        qs => {
            _source         => "list",
            _source_exclude => "list",
            _source_include => "list",
            fields          => "list",
            filter_path     => "list",
            preference      => "string",
            realtime        => "boolean",
            refresh         => "boolean",
        },
    },

    'mlt' => {
        body  => {},
        doc   => "search-more-like-this",
        parts => {
            id    => { required => 1 },
            index => { required => 1 },
            type  => { required => 1 },
        },
        paths => [
            [   { id => 2, index => 0, type => 1 },
                "{index}", "{type}", "{id}", "_mlt",
            ],
        ],
        qs => {
            boost_terms            => "number",
            filter_path            => "list",
            max_doc_freq           => "number",
            max_query_terms        => "number",
            max_word_len           => "number",
            min_doc_freq           => "number",
            min_term_freq          => "number",
            min_word_len           => "number",
            mlt_fields             => "list",
            percent_terms_to_match => "number",
            routing                => "string",
            search_from            => "number",
            search_indices         => "list",
            search_query_hint      => "string",
            search_scroll          => "string",
            search_size            => "number",
            search_source          => "string",
            search_type            => "string",
            search_types           => "list",
            stop_words             => "list",
        },
    },

    'msearch' => {
        body => { required => 1 },
        doc  => "search-multi-search",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_msearch" ],
            [ { index => 0 }, "{index}", "_msearch" ],
            [ {}, "_msearch" ],
        ],
        qs        => { filter_path => "list", search_type => "enum" },
        serialize => "bulk",
    },

    'percolate' => {
        body => { required => 1 },
        doc  => "search-percolate",
        parts => { index => { required => 1 }, type => { required => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_percolate" ],
        ],
        qs => { filter_path => "list", prefer_local => "boolean" },
    },

    'ping' => {
        doc    => "",
        method => "HEAD",
        parts  => {},
        paths  => [ [ {} ] ],
        qs     => {}
    },

    'scroll' => {
        body  => {},
        doc   => "search-request-scroll",
        parts => { scroll_id => {} },
        paths => [
            [ { scroll_id => 2 }, "_search", "scroll", "{scroll_id}" ],
            [ {}, "_search", "scroll" ],
        ],
        qs => { filter_path => "list", scroll => "time" },
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
            _source                  => "list",
            _source_exclude          => "list",
            _source_include          => "list",
            analyze_wildcard         => "boolean",
            analyzer                 => "string",
            default_operator         => "enum",
            df                       => "string",
            explain                  => "boolean",
            fields                   => "list",
            filter_path              => "list",
            from                     => "number",
            ignore_indices           => "enum",
            indices_boost            => "list",
            lenient                  => "boolean",
            lowercase_expanded_terms => "boolean",
            preference               => "string",
            q                        => "string",
            routing                  => "list",
            scroll                   => "time",
            search_type              => "enum",
            size                     => "number",
            sort                     => "list",
            source                   => "string",
            stats                    => "list",
            suggest_field            => "string",
            suggest_mode             => "enum",
            suggest_size             => "number",
            suggest_text             => "string",
            timeout                  => "time",
            version                  => "boolean",
        },
    },

    'suggest' => {
        body   => {},
        doc    => "search-search",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_suggest" ], [ {}, "_suggest" ] ],
        qs => {
            filter_path    => "list",
            ignore_indices => "enum",
            preference     => "string",
            routing        => "string",
            source         => "string",
        },
    },

    'update' => {
        body   => {},
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
            consistency       => "enum",
            fields            => "list",
            filter_path       => "list",
            lang              => "string",
            parent            => "string",
            percolate         => "string",
            refresh           => "boolean",
            replication       => "enum",
            retry_on_conflict => "number",
            routing           => "string",
            script            => "string",
            timeout           => "time",
            timestamp         => "time",
            ttl               => "time",
            version           => "number",
            version_type      => "enum",
        },
    },

    'cluster.get_settings' => {
        doc   => "cluster-update-settings",
        parts => {},
        paths => [ [ {}, "_cluster", "settings" ] ],
        qs => { filter_path => "list" },
    },

    'cluster.health' => {
        doc   => "cluster-health",
        parts => { index => {} },
        paths => [
            [ { index => 2 }, "_cluster", "health", "{index}" ],
            [ {}, "_cluster", "health" ],
        ],
        qs => {
            filter_path                => "list",
            level                      => "enum",
            local                      => "boolean",
            master_timeout             => "time",
            timeout                    => "time",
            wait_for_active_shards     => "number",
            wait_for_nodes             => "string",
            wait_for_relocating_shards => "number",
            wait_for_status            => "enum",
        },
    },

    'cluster.node_hot_threads' => {
        doc   => "cluster-nodes-hot-threads",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 1 }, "_nodes", "{node_id}", "hot_threads" ],
            [ {}, "_nodes", "hot_threads" ],
        ],
        qs => {
            filter_path => "list",
            interval    => "time",
            snapshots   => "number",
            threads     => "number",
            type        => "enum",
        },
    },

    'cluster.node_info' => {
        doc   => "cluster-nodes-info",
        parts => { node_id => { multi => 1 } },
        paths =>
            [ [ { node_id => 1 }, "_nodes", "{node_id}" ], [ {}, "_nodes" ] ],
        qs => {
            all         => "boolean",
            clear       => "boolean",
            filter_path => "list",
            http        => "boolean",
            jvm         => "boolean",
            network     => "boolean",
            os          => "boolean",
            plugin      => "boolean",
            process     => "boolean",
            settings    => "boolean",
            thread_pool => "boolean",
            timeout     => "time",
            transport   => "boolean",
        },
    },

    'cluster.node_shutdown' => {
        doc    => "cluster-nodes-shutdown",
        method => "POST",
        parts  => { node_id => { multi => 1 } },
        paths  => [
            [   { node_id => 2 }, "_cluster",
                "nodes", "{node_id}",
                "_shutdown"
            ],
            [ {}, "_shutdown" ],
        ],
        qs => { delay => "time", exit => "boolean", filter_path => "list" },
    },

    'cluster.node_stats' => {
        doc   => "cluster-nodes-stats",
        parts => {
            fields        => { multi => 1 },
            metric        => {},
            metric_family => {},
            node_id       => { multi => 1 },
        },
        paths => [
            [   { fields => 5, metric => 4, node_id => 1 },
                "_nodes", "{node_id}", "stats", "indices", "{metric}",
                "{fields}",
            ],
            [   { fields => 4, metric => 3 }, "_nodes",
                "stats",    "indices",
                "{metric}", "{fields}",
            ],
            [   { metric_family => 3, node_id => 1 }, "_nodes",
                "{node_id}", "stats",
                "{metric_family}",
            ],
            [ { metric_family => 2 }, "_nodes", "stats", "{metric_family}" ],
            [ { node_id => 1 }, "_nodes", "{node_id}", "stats" ],
            [ {}, "_nodes", "stats" ],
        ],
        qs => {
            all         => "boolean",
            clear       => "boolean",
            filter_path => "list",
            fs          => "boolean",
            http        => "boolean",
            indices     => "boolean",
            jvm         => "boolean",
            network     => "boolean",
            os          => "boolean",
            process     => "boolean",
            thread_pool => "boolean",
            transport   => "boolean",
        },
    },

    'cluster.pending_tasks' => {
        doc   => "cluster-pending",
        parts => {},
        paths => [ [ {}, "_cluster", "pending_tasks" ] ],
        qs    => {
            filter_path    => "list",
            local          => "boolean",
            master_timeout => "time"
        },
    },

    'cluster.put_settings' => {
        body   => {},
        doc    => "cluster-update-settings",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_cluster", "settings" ] ],
        qs => { filter_path => "list" },
    },

    'cluster.reroute' => {
        body   => {},
        doc    => "cluster-reroute",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_cluster", "reroute" ] ],
        qs     => {
            dry_run         => "boolean",
            filter_metadata => "boolean",
            filter_path     => "list",
        },
    },

    'cluster.state' => {
        doc   => "cluster-state",
        parts => {},
        paths => [ [ {}, "_cluster", "state" ] ],
        qs    => {
            filter_blocks          => "boolean",
            filter_index_templates => "boolean",
            filter_indices         => "list",
            filter_metadata        => "boolean",
            filter_nodes           => "boolean",
            filter_path            => "list",
            filter_routing_table   => "boolean",
            local                  => "boolean",
            master_timeout         => "time",
        },
    },

    'indices.analyze' => {
        body  => {},
        doc   => "indices-analyze",
        parts => { index => {} },
        paths =>
            [ [ { index => 0 }, "{index}", "_analyze" ], [ {}, "_analyze" ] ],
        qs => {
            analyzer     => "string",
            field        => "string",
            filter_path  => "list",
            filters      => "list",
            format       => "enum",
            prefer_local => "boolean",
            text         => "string",
            tokenizer    => "string",
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
            fielddata      => "boolean",
            fields         => "list",
            filter         => "boolean",
            filter_cache   => "boolean",
            filter_keys    => "boolean",
            filter_path    => "list",
            id             => "boolean",
            id_cache       => "boolean",
            ignore_indices => "enum",
            recycler       => "boolean",
        },
    },

    'indices.close' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_close" ] ],
        qs     => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'indices.create' => {
        body   => {},
        doc    => "indices-create-index",
        method => "PUT",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}" ] ],
        qs     => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'indices.delete' => {
        doc    => "indices-delete-index",
        method => "DELETE",
        parts  => { index => { multi => 1 } },
        paths  => [ [ { index => 0 }, "{index}" ], [ {} ] ],
        qs     => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'indices.delete_alias' => {
        doc    => "indices-aliases",
        method => "DELETE",
        parts  => { index => { required => 1 }, name => { required => 1 } },
        paths =>
            [ [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ] ],
        qs => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'indices.delete_mapping' => {
        doc    => "indices-delete-mapping",
        method => "DELETE",
        parts  => {
            index => { multi    => 1, required => 1 },
            type  => { required => 1 }
        },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mapping" ]
        ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'indices.delete_template' => {
        doc    => "indices-templates",
        method => "DELETE",
        parts  => { name => { required => 1 } },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs     => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'indices.delete_warmer' => {
        doc    => "indices-warmers",
        method => "DELETE",
        parts  => {
            index => { multi => 1, required => 1 },
            name  => {},
            type => { multi => 1 },
        },
        paths => [
            [   { index => 0, name => 3, type => 1 },
                "{index}", "{type}", "_warmer", "{name}",
            ],
            [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ],
            [ { index => 0 }, "{index}", "_warmer" ],
        ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'indices.exists' => {
        doc    => "indices-get-settings",
        method => "HEAD",
        parts  => { index => { multi => 1, required => 1 } },
        paths => [ [ { index => 0 }, "{index}" ] ],
        qs => {},
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
            [ { name => 1 }, "_alias", "{name}" ],
        ],
        qs => { ignore_indices => "enum" },
    },

    'indices.exists_type' => {
        doc    => "indices-types-exists",
        method => "HEAD",
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1, required => 1 },
        },
        paths => [ [ { index => 0, type => 1 }, "{index}", "{type}" ] ],
        qs => { ignore_indices => "enum" },
    },

    'indices.flush' => {
        doc    => "indices-flush",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_flush" ], [ {}, "_flush" ] ],
        qs => {
            filter_path    => "list",
            force          => "boolean",
            full           => "boolean",
            ignore_indices => "enum",
            refresh        => "boolean",
        },
    },

    'indices.get_alias' => {
        doc   => "indices-aliases",
        parts => {
            index => { multi => 1 },
            name  => { multi => 1, required => 1 }
        },
        paths => [
            [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ],
            [ { name => 1 }, "_alias", "{name}" ],
        ],
        qs => { filter_path => "list", ignore_indices => "enum" },
    },

    'indices.get_aliases' => {
        doc   => "indices-aliases",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_aliases" ], [ {}, "_aliases" ] ],
        qs => { filter_path => "list", timeout => "time" },
    },

    'indices.get_field_mapping' => {
        doc   => "indices-get-field-mapping",
        parts => {
            field => { multi => 1, required => 1 },
            index => { multi => 1 },
            type  => { multi => 1 },
        },
        paths => [
            [   { field => 4, index => 0, type => 1 }, "{index}",
                "{type}", "_mapping",
                "field",  "{field}",
            ],
            [   { field => 3, index => 0 }, "{index}",
                "_mapping", "field",
                "{field}",
            ],
            [ { field => 2 }, "_mapping", "field", "{field}" ],
        ],
        qs => { filter_path => "list", include_defaults => "boolean" },
    },

    'indices.get_mapping' => {
        doc   => "indices-get-mapping",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mapping" ],
            [ { index => 0 }, "{index}", "_mapping" ],
            [ {}, "_mapping" ],
        ],
        qs => { filter_path => "list" },
    },

    'indices.get_settings' => {
        doc   => "indices-get-mapping",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_settings" ],
            [ {}, "_settings" ]
        ],
        qs => { filter_path => "list" },
    },

    'indices.get_template' => {
        doc   => "indices-templates",
        parts => { name => {} },
        paths =>
            [ [ { name => 1 }, "_template", "{name}" ], [ {}, "_template" ] ],
        qs => { filter_path => "list" },
    },

    'indices.get_warmer' => {
        doc   => "indices-warmers",
        parts => {
            index => { multi => 1, required => 1 },
            name  => {},
            type => { multi => 1 },
        },
        paths => [
            [   { index => 0, name => 3, type => 1 },
                "{index}", "{type}", "_warmer", "{name}",
            ],
            [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ],
            [ { index => 0 }, "{index}", "_warmer" ],
        ],
        qs => { filter_path => "list" },
    },

    'indices.open' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_open" ] ],
        qs     => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'indices.optimize' => {
        doc    => "indices-optimize",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_optimize" ],
            [ {}, "_optimize" ]
        ],
        qs => {
            filter_path          => "list",
            flush                => "boolean",
            ignore_indices       => "enum",
            max_num_segments     => "number",
            only_expunge_deletes => "boolean",
            refresh              => "boolean",
            wait_for_merge       => "boolean",
        },
    },

    'indices.put_alias' => {
        body   => {},
        doc    => "indices-aliases",
        method => "PUT",
        parts  => { index => { required => 1 }, name => { required => 1 } },
        paths  => [
            [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ],
            [ { index => 0 }, "{index}", "_alias" ],
            [ { name  => 1 }, "_alias",  "{name}" ],
            [ {}, "_alias" ],
        ],
        qs => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'indices.put_mapping' => {
        body   => { required => 1 },
        doc    => "indices-put-mapping",
        method => "PUT",
        parts  => {
            index => { multi    => 1, required => 1 },
            type  => { required => 1 }
        },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mapping" ]
        ],
        qs => {
            filter_path      => "list",
            ignore_conflicts => "boolean",
            master_timeout   => "time",
            timeout          => "time",
        },
    },

    'indices.put_settings' => {
        body   => { required => 1 },
        doc    => "indices-update-settings",
        method => "PUT",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_settings" ],
            [ {}, "_settings" ]
        ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'indices.put_template' => {
        body   => { required => 1 },
        doc    => "indices-templates",
        method => "PUT",
        parts => { name => { required => 1 } },
        paths => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs => {
            filter_path    => "list",
            master_timeout => "time",
            order          => "number",
            timeout        => "time",
        },
    },

    'indices.put_warmer' => {
        body   => { required => 1 },
        doc    => "indices-warmers",
        method => "PUT",
        parts  => {
            index => { multi    => 1, required => 1 },
            name  => { required => 1 },
            type  => { multi    => 1 },
        },
        paths => [
            [   { index => 0, name => 3, type => 1 },
                "{index}", "{type}", "_warmer", "{name}",
            ],
            [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ],
        ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'indices.refresh' => {
        doc    => "indices-refresh",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_refresh" ], [ {}, "_refresh" ] ],
        qs => { filter_path => "list", ignore_indices => "enum" },
    },

    'indices.segments' => {
        doc   => "indices-segments",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_segments" ],
            [ {}, "_segments" ]
        ],
        qs => { filter_path => "list", ignore_indices => "enum" },
    },

    'indices.snapshot_index' => {
        doc    => "indices-gateway-snapshot",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_gateway", "snapshot" ],
            [ {}, "_gateway", "snapshot" ],
        ],
        qs => { filter_path => "list", ignore_indices => "enum" },
    },

    'indices.stats' => {
        doc   => "indices-stats",
        parts => {
            fields         => { multi => 1 },
            index          => { multi => 1 },
            indexing_types => { multi => 1 },
            metric_family  => {},
            search_groups  => { multi => 1 },
        },
        paths => [
            [   { fields => 3, index => 0 }, "{index}",
                "_stats", "fielddata",
                "{fields}",
            ],
            [   { index => 0, metric_family => 2 }, "{index}",
                "_stats", "{metric_family}",
            ],
            [   { index => 0, search_groups => 3 }, "{index}",
                "_stats", "search",
                "{search_groups}",
            ],
            [ { fields => 2 }, "_stats", "fielddata", "{fields}" ],
            [ { index => 0 }, "{index}", "_stats" ],
            [   { indexing_types => 2 }, "_stats",
                "indexing", "{indexing_types}",
            ],
            [ { metric_family => 1 }, "_stats", "{metric_family}" ],
            [ { search_groups => 2 }, "_stats", "search", "{search_groups}" ],
            [ {}, "_stats" ],
        ],
        qs => {
            all               => "boolean",
            clear             => "boolean",
            completion        => "boolean",
            completion_fields => "list",
            docs              => "boolean",
            fielddata         => "boolean",
            fielddata_fields  => "list",
            filter_cache      => "boolean",
            filter_path       => "list",
            flush             => "boolean",
            get               => "boolean",
            groups            => "boolean",
            id_cache          => "boolean",
            ignore_indices    => "enum",
            indexing          => "boolean",
            merge             => "boolean",
            refresh           => "boolean",
            search            => "boolean",
            store             => "boolean",
            warmer            => "boolean",
        },
    },

    'indices.status' => {
        doc   => "indices-status",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_status" ], [ {}, "_status" ] ],
        qs => {
            filter_path    => "list",
            ignore_indices => "enum",
            recovery       => "boolean",
            snapshot       => "boolean",
        },
    },

    'indices.update_aliases' => {
        body   => { required => 1 },
        doc    => "indices-aliases",
        method => "POST",
        parts => { index => { multi => 1 } },
        paths => [ [ {}, "_aliases" ] ],
        qs => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
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
            explain        => "boolean",
            filter_path    => "list",
            ignore_indices => "enum",
            q              => "string",
            source         => "string",
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
is the definition for the L<Search::Elasticsearch::Client::0_90::Direct/index()> method:

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

L<Search::Elasticsearch::Client::0_90::Direct>

=back
