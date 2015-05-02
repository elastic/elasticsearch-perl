package Search::Elasticsearch::Role::API::0_90;

use Moo::Role;

use Search::Elasticsearch::Util qw(throw);
use Search::Elasticsearch::Util::API::QS qw(qs_init);
use namespace::clean;

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

#=== AUTOGEN - START ===

    'bulk' => {
        body            => { required => 1 },
        doc             => "docs-bulk",
        index_when_type => 1,
        method          => "POST",
        parts => { index => {}, type => {} },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_bulk" ],
            [ { index => 0 }, "{index}", "_bulk" ],
            [ {}, "_bulk" ],
        ],
        qs        => [ "consistency", "refresh", "replication", "timeout" ],
        serialize => "bulk",
    },

    'clear_scroll' => {
        doc    => "search-request-scroll",
        method => "DELETE",
        parts  => { scroll_id => { multi => 1 } },
        paths =>
            [ [ { scroll_id => 2 }, "_search", "scroll", "{scroll_id}" ] ],
        qs => [],
    },

    'count' => {
        body   => {},
        doc    => "search-count",
        method => "POST",
        parts  => { index => { multi => 1 }, type => { multi => 1 } },
        paths  => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_count" ],
            [ { type => 1 }, "_all", "{type}", "_count" ],
            [ { index => 0 }, "{index}", "_count" ],
            [ {}, "_count" ],
        ],
        qs => [
            "ignore_indices", "min_score", "preference", "routing",
            "source"
        ],
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
        qs => [
            "consistency", "parent",  "refresh", "replication",
            "routing",     "timeout", "version", "version_type",
        ],
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
        qs => [
            "analyzer",         "consistency",
            "default_operator", "df",
            "ignore_indices",   "q",
            "replication",      "routing",
            "source",           "timeout",
        ],
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
        qs => [ "parent", "preference", "realtime", "refresh", "routing" ],
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
        qs => [
            "_source",         "_source_exclude",
            "_source_include", "analyze_wildcard",
            "analyzer",        "default_operator",
            "df",              "fields",
            "lenient",         "lowercase_expanded_terms",
            "parent",          "preference",
            "q",               "routing",
            "source",
        ],
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
        qs => [
            "_source",         "_source_exclude",
            "_source_include", "fields",
            "parent",          "preference",
            "realtime",        "refresh",
            "routing",
        ],
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
        qs => [
            "_source",         "_source_exclude",
            "_source_include", "parent",
            "preference",      "realtime",
            "refresh",         "routing",
            "version",         "version_type",
        ],
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
        qs => [
            "consistency", "op_type",     "parent",  "percolate",
            "refresh",     "replication", "routing", "timeout",
            "timestamp",   "ttl",         "version", "version_type",
        ],
    },

    'info' => { doc => "", parts => {}, paths => [ [ {} ] ], qs => [] },

    'mget' => {
        body            => { required => 1 },
        doc             => "docs-multi-get",
        index_when_type => 1,
        parts => { index => {}, type => {} },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mget" ],
            [ { index => 0 }, "{index}", "_mget" ],
            [ {}, "_mget" ],
        ],
        qs => [
            "_source",         "_source_exclude",
            "_source_include", "fields",
            "preference",      "realtime",
            "refresh",
        ],
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
        qs => [
            "boost_terms",            "max_doc_freq",
            "max_query_terms",        "max_word_len",
            "min_doc_freq",           "min_term_freq",
            "min_word_len",           "mlt_fields",
            "percent_terms_to_match", "routing",
            "search_from",            "search_indices",
            "search_scroll",          "search_size",
            "search_source",          "search_type",
            "search_types",           "stop_words",
        ],
    },

    'msearch' => {
        body => { required => 1 },
        doc  => "search-multi-search",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_msearch" ],
            [ { type => 1 }, "_all", "{type}", "_msearch" ],
            [ { index => 0 }, "{index}", "_msearch" ],
            [ {}, "_msearch" ],
        ],
        qs        => ["search_type"],
        serialize => "bulk",
    },

    'percolate' => {
        body => { required => 1 },
        doc  => "search-percolate",
        parts => { index => { required => 1 }, type => { required => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_percolate" ],
        ],
        qs => ["prefer_local"],
    },

    'ping' => {
        doc    => "",
        method => "HEAD",
        parts  => {},
        paths  => [ [ {} ] ],
        qs     => []
    },

    'scroll' => {
        body  => {},
        doc   => "search-request-scroll",
        parts => { scroll_id => {} },
        paths => [
            [ { scroll_id => 2 }, "_search", "scroll", "{scroll_id}" ],
            [ {}, "_search", "scroll" ],
        ],
        qs => ["scroll"],
    },

    'search' => {
        body  => {},
        doc   => "search-search",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_search" ],
            [ { type => 1 }, "_all", "{type}", "_search" ],
            [ { index => 0 }, "{index}", "_search" ],
            [ {}, "_search" ],
        ],
        qs => [
            "_source",                  "_source_exclude",
            "_source_include",          "analyze_wildcard",
            "analyzer",                 "default_operator",
            "df",                       "explain",
            "fields",                   "from",
            "ignore_indices",           "lenient",
            "lowercase_expanded_terms", "preference",
            "q",                        "routing",
            "scroll",                   "search_type",
            "size",                     "sort",
            "source",                   "stats",
            "suggest_field",            "suggest_mode",
            "suggest_size",             "suggest_text",
            "timeout",                  "version",
        ],
    },

    'suggest' => {
        body   => {},
        doc    => "search-search",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_suggest" ], [ {}, "_suggest" ] ],
        qs => [ "ignore_indices", "preference", "routing", "source" ],
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
        qs => [
            "consistency", "fields",
            "lang",        "parent",
            "percolate",   "refresh",
            "replication", "retry_on_conflict",
            "routing",     "script",
            "timeout",     "timestamp",
            "ttl",         "version",
            "version_type",
        ],
    },

    'cluster.get_settings' => {
        doc   => "cluster-update-settings",
        parts => {},
        paths => [ [ {}, "_cluster", "settings" ] ],
        qs    => [],
    },

    'cluster.health' => {
        doc   => "cluster-health",
        parts => { index => {} },
        paths => [
            [ { index => 2 }, "_cluster", "health", "{index}" ],
            [ {}, "_cluster", "health" ],
        ],
        qs => [
            "level",                      "local",
            "master_timeout",             "timeout",
            "wait_for_active_shards",     "wait_for_nodes",
            "wait_for_relocating_shards", "wait_for_status",
        ],
    },

    'cluster.node_hot_threads' => {
        doc   => "cluster-nodes-hot-threads",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 1 }, "_nodes", "{node_id}", "hot_threads" ],
            [ {}, "_nodes", "hot_threads" ],
        ],
        qs => [ "interval", "snapshots", "threads", "type" ],
    },

    'cluster.node_info' => {
        doc   => "cluster-nodes-info",
        parts => { node_id => { multi => 1 } },
        paths =>
            [ [ { node_id => 1 }, "_nodes", "{node_id}" ], [ {}, "_nodes" ] ],
        qs => [
            "all",      "clear",       "http",    "jvm",
            "network",  "os",          "plugin",  "process",
            "settings", "thread_pool", "timeout", "transport",
        ],
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
        qs => [ "delay", "exit" ],
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
            [   { fields => 5, node_id => 1 }, "_nodes",
                "{node_id}", "stats",
                "indices",   "_all",
                "{fields}",
            ],
            [   { fields => 4, metric => 3 }, "_nodes",
                "stats",    "indices",
                "{metric}", "{fields}",
            ],
            [   { fields => 4 }, "_nodes", "stats", "indices",
                "_all", "{fields}"
            ],
            [   { metric_family => 3, node_id => 1 }, "_nodes",
                "{node_id}", "stats",
                "{metric_family}",
            ],
            [ { metric_family => 2 }, "_nodes", "stats", "{metric_family}" ],
            [ { node_id => 1 }, "_nodes", "{node_id}", "stats" ],
            [ {}, "_nodes", "stats" ],
        ],
        qs => [
            "all",     "clear",       "fs",      "http",
            "indices", "jvm",         "network", "os",
            "process", "thread_pool", "transport",
        ],
    },

    'cluster.pending_tasks' => {
        doc   => "cluster-pending",
        parts => {},
        paths => [ [ {}, "_cluster", "pending_tasks" ] ],
        qs => [ "local", "master_timeout" ],
    },

    'cluster.put_settings' => {
        body   => {},
        doc    => "cluster-update-settings",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_cluster", "settings" ] ],
        qs     => [],
    },

    'cluster.reroute' => {
        body   => {},
        doc    => "cluster-reroute",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_cluster", "reroute" ] ],
        qs => [ "dry_run", "filter_metadata" ],
    },

    'cluster.state' => {
        doc   => "cluster-state",
        parts => {},
        paths => [ [ {}, "_cluster", "state" ] ],
        qs    => [
            "filter_blocks",  "filter_index_templates",
            "filter_indices", "filter_metadata",
            "filter_nodes",   "filter_routing_table",
            "local",          "master_timeout",
        ],
    },

    'indices.analyze' => {
        body  => {},
        doc   => "indices-analyze",
        parts => { index => {} },
        paths =>
            [ [ { index => 0 }, "{index}", "_analyze" ], [ {}, "_analyze" ] ],
        qs => [
            "analyzer",     "field", "filters", "format",
            "prefer_local", "text",  "tokenizer",
        ],
    },

    'indices.clear_cache' => {
        doc    => "indices-clearcache",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_cache", "clear" ],
            [ {}, "_cache", "clear" ],
        ],
        qs => [
            "fielddata",   "fields",
            "filter",      "filter_cache",
            "filter_keys", "id",
            "id_cache",    "ignore_indices",
            "recycler",
        ],
    },

    'indices.close' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_close" ] ],
        qs => [ "master_timeout", "timeout" ],
    },

    'indices.create' => {
        body   => {},
        doc    => "indices-create-index",
        method => "PUT",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}" ] ],
        qs => [ "master_timeout", "timeout" ],
    },

    'indices.delete' => {
        doc    => "indices-delete-index",
        method => "DELETE",
        parts  => { index => { multi => 1 } },
        paths  => [ [ { index => 0 }, "{index}" ], [ {} ] ],
        qs => [ "master_timeout", "timeout" ],
    },

    'indices.delete_alias' => {
        doc    => "indices-aliases",
        method => "DELETE",
        parts  => { index => { required => 1 }, name => { required => 1 } },
        paths =>
            [ [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ] ],
        qs => [ "master_timeout", "timeout" ],
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
        qs => ["master_timeout"],
    },

    'indices.delete_template' => {
        doc    => "indices-templates",
        method => "DELETE",
        parts  => { name => { required => 1 } },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs => [ "master_timeout", "timeout" ],
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
        qs => ["master_timeout"],
    },

    'indices.exists' => {
        doc    => "indices-get-settings",
        method => "HEAD",
        parts  => { index => { multi => 1, required => 1 } },
        paths => [ [ { index => 0 }, "{index}" ] ],
        qs => [],
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
        qs => ["ignore_indices"],
    },

    'indices.exists_type' => {
        doc    => "indices-types-exists",
        method => "HEAD",
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1, required => 1 },
        },
        paths => [ [ { index => 0, type => 1 }, "{index}", "{type}" ] ],
        qs => ["ignore_indices"],
    },

    'indices.flush' => {
        doc    => "indices-flush",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_flush" ], [ {}, "_flush" ] ],
        qs => [ "force", "full", "ignore_indices", "refresh" ],
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
        qs => ["ignore_indices"],
    },

    'indices.get_aliases' => {
        doc   => "indices-aliases",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_aliases" ], [ {}, "_aliases" ] ],
        qs => ["timeout"],
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
            [   { field => 4, type => 1 }, "_all",
                "{type}", "_mapping",
                "field",  "{field}",
            ],
            [   { field => 3, index => 0 }, "{index}",
                "_mapping", "field",
                "{field}",
            ],
            [ { field => 2 }, "_mapping", "field", "{field}" ],
        ],
        qs => ["include_defaults"],
    },

    'indices.get_mapping' => {
        doc   => "indices-get-mapping",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mapping" ],
            [ { type => 1 }, "_all", "{type}", "_mapping" ],
            [ { index => 0 }, "{index}", "_mapping" ],
            [ {}, "_mapping" ],
        ],
        qs => [],
    },

    'indices.get_settings' => {
        doc   => "indices-get-mapping",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_settings" ],
            [ {}, "_settings" ]
        ],
        qs => [],
    },

    'indices.get_template' => {
        doc   => "indices-templates",
        parts => { name => {} },
        paths =>
            [ [ { name => 1 }, "_template", "{name}" ], [ {}, "_template" ] ],
        qs => [],
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
        qs => [],
    },

    'indices.open' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_open" ] ],
        qs => [ "master_timeout", "timeout" ],
    },

    'indices.optimize' => {
        doc    => "indices-optimize",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_optimize" ],
            [ {}, "_optimize" ]
        ],
        qs => [
            "flush",            "ignore_indices",
            "max_num_segments", "only_expunge_deletes",
            "refresh",          "wait_for_merge",
        ],
    },

    'indices.put_alias' => {
        body   => {},
        doc    => "indices-aliases",
        method => "PUT",
        parts  => { index => { required => 1 }, name => { required => 1 } },
        paths  => [
            [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ],
            [ { name  => 1 }, "_alias",  "{name}" ],
            [ { index => 0 }, "{index}", "_alias" ],
            [ {}, "_alias" ],
        ],
        qs => [ "master_timeout", "timeout" ],
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
        qs => [ "ignore_conflicts", "master_timeout", "timeout" ],
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
        qs => ["master_timeout"],
    },

    'indices.put_template' => {
        body   => { required => 1 },
        doc    => "indices-templates",
        method => "PUT",
        parts => { name => { required => 1 } },
        paths => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs => [ "master_timeout", "order", "timeout" ],
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
        qs => ["master_timeout"],
    },

    'indices.refresh' => {
        doc    => "indices-refresh",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_refresh" ], [ {}, "_refresh" ] ],
        qs => ["ignore_indices"],
    },

    'indices.segments' => {
        doc   => "indices-segments",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_segments" ],
            [ {}, "_segments" ]
        ],
        qs => ["ignore_indices"],
    },

    'indices.snapshot_index' => {
        doc    => "indices-gateway-snapshot",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths  => [
            [ { index => 0 }, "{index}", "_gateway", "snapshot" ],
            [ {}, "_gateway", "snapshot" ],
        ],
        qs => ["ignore_indices"],
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
            [   { index => 0, search_groups => 3 }, "{index}",
                "_stats", "search",
                "{search_groups}",
            ],
            [   { index => 0, metric_family => 2 }, "{index}",
                "_stats", "{metric_family}",
            ],
            [   { fields => 3, index => 0 }, "{index}",
                "_stats", "fielddata",
                "{fields}",
            ],
            [ { metric_family => 1 }, "_stats",  "{metric_family}" ],
            [ { fields        => 2 }, "_stats",  "fielddata", "{fields}" ],
            [ { index         => 0 }, "{index}", "_stats" ],
            [   { indexing_types => 2 }, "_stats",
                "indexing", "{indexing_types}",
            ],
            [ { search_groups => 2 }, "_stats", "search", "{search_groups}" ],
            [ {}, "_stats" ],
        ],
        qs => [
            "all",              "clear",
            "completion",       "completion_fields",
            "docs",             "fielddata",
            "fielddata_fields", "filter_cache",
            "flush",            "get",
            "groups",           "id_cache",
            "ignore_indices",   "indexing",
            "merge",            "refresh",
            "search",           "store",
            "warmer",
        ],
    },

    'indices.status' => {
        doc   => "indices-status",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_status" ], [ {}, "_status" ] ],
        qs => [ "ignore_indices", "recovery", "snapshot" ],
    },

    'indices.update_aliases' => {
        body   => { required => 1 },
        doc    => "indices-aliases",
        method => "POST",
        parts => { index => { multi => 1 } },
        paths => [ [ {}, "_aliases" ] ],
        qs => [ "master_timeout", "timeout" ],
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
            [ { type => 1 }, "_all", "{type}", "_validate", "query" ],
            [ { index => 0 }, "{index}", "_validate", "query" ],
            [ {}, "_validate", "query" ],
        ],
        qs => [ "explain", "ignore_indices", "q", "source" ],
    },

#=== AUTOGEN - END ===

);

for ( values %API ) {
    $_->{qs_handlers} = qs_init( @{ $_->{qs} } );
}

1;

__END__

# ABSTRACT: This class contains the spec for the Elasticsearch APIs

=head1 DESCRIPTION

All of the Elasticsearch APIs are defined in this role. The example given below
is the definition for the L<Search::Elasticsearch::Client::Direct/index()> method:

    'index' => {
        body => {
            desc     => 'The document',
            required => 1
        },

        doc    => '/api/index_/',
        method => 'PUT',
        path   => '{index}/{type}/{id|blank}',
        qs     => [
            'consistency', 'op_type',     'parent',  'percolate',
            'refresh',     'replication', 'routing', 'timeout',
            'timestamp',   'ttl',         'version', 'version_type'
        ],
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

L<Search::Elasticsearch::Util::API::Path>

=item *

L<Search::Elasticsearch::Util::API::QS>

=item *

L<Search::Elasticsearch::Client::Direct>

=back
