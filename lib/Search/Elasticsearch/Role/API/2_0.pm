package Search::Elasticsearch::Role::API::2_0;

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
        qs        => [ "consistency", "refresh", "routing", "timeout" ],
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
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "min_score",
            "preference",         "routing",
        ],
    },

    'count_percolate' => {
        body  => {},
        doc   => "search-percolate",
        parts => {
            id    => {},
            index => { required => 1 },
            type  => { required => 1 }
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}",     "{id}",
                "_percolate", "count",
            ],
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_percolate",
                "count",
            ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "percolate_index",
            "percolate_type",     "preference",
            "routing",            "version",
            "version_type",
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
            "consistency", "parent",  "refresh", "routing",
            "timeout",     "version", "version_type",
        ],
    },

    'delete_script' => {
        doc    => "modules-scripting",
        method => "DELETE",
        parts  => { id => { required => 1 }, lang => { required => 1 } },
        paths => [ [ { id => 2, lang => 1 }, "_scripts", "{lang}", "{id}" ] ],
        qs => [ "version", "version_type" ],
    },

    'delete_template' => {
        doc    => "search-template",
        method => "DELETE",
        parts  => { id => {} },
        paths  => [ [ { id => 2 }, "_search", "template", "{id}" ] ],
        qs => [ "version", "version_type" ],
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
        ],
    },

    'field_stats' => {
        doc   => "search-field-stats",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_field_stats" ],
            [ {}, "_field_stats" ],
        ],
        qs => [
            "allow_no_indices", "expand_wildcards",
            "fields",           "ignore_unavailable",
            "level",
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
            "routing",         "version",
            "version_type",
        ],
    },

    'get_script' => {
        doc   => "modules-scripting",
        parts => { id => { required => 1 }, lang => { required => 1 } },
        paths => [ [ { id => 2, lang => 1 }, "_scripts", "{lang}", "{id}" ] ],
        qs => [ "version", "version_type" ],
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

    'get_template' => {
        doc   => "search-template",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_search", "template", "{id}" ] ],
        qs => [ "version", "version_type" ],
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
            "consistency", "op_type", "parent",    "refresh",
            "routing",     "timeout", "timestamp", "ttl",
            "version",     "version_type",
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
            "max_query_terms",        "max_word_length",
            "min_doc_freq",           "min_term_freq",
            "min_word_length",        "mlt_fields",
            "percent_terms_to_match", "routing",
            "search_from",            "search_indices",
            "search_scroll",          "search_size",
            "search_source",          "search_type",
            "search_types",           "stop_words",
        ],
    },

    'mpercolate' => {
        body            => { required => 1 },
        doc             => "search-percolate",
        index_when_type => 1,
        parts => { index => {}, type => {} },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mpercolate" ],
            [ { index => 0 }, "{index}", "_mpercolate" ],
            [ {}, "_mpercolate" ],
        ],
        qs =>
            [ "allow_no_indices", "expand_wildcards", "ignore_unavailable" ],
        serialize => "bulk",
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

    'mtermvectors' => {
        body            => {},
        doc             => "docs-multi-termvectors",
        index_when_type => 1,
        parts           => { index => {}, type => {} },
        paths           => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_mtermvectors"
            ],
            [ { index => 0 }, "{index}", "_mtermvectors" ],
            [ {}, "_mtermvectors" ],
        ],
        qs => [
            "field_statistics", "fields",
            "ids",              "offsets",
            "parent",           "payloads",
            "positions",        "preference",
            "realtime",         "routing",
            "term_statistics",  "version",
            "version_type",
        ],
    },

    'percolate' => {
        body  => {},
        doc   => "search-percolate",
        parts => {
            id    => {},
            index => { required => 1 },
            type  => { required => 1 }
        },
        paths => [
            [   { id => 2, index => 0, type => 1 }, "{index}",
                "{type}", "{id}",
                "_percolate",
            ],
            [ { index => 0, type => 1 }, "{index}", "{type}", "_percolate" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "percolate_format",
            "percolate_index",    "percolate_preference",
            "percolate_routing",  "percolate_type",
            "preference",         "routing",
            "version",            "version_type",
        ],
    },

    'ping' => {
        doc    => "",
        method => "HEAD",
        parts  => {},
        paths  => [ [ {} ] ],
        qs     => []
    },

    'put_script' => {
        body   => { required => 1 },
        doc    => "modules-scripting",
        method => "PUT",
        parts => { id => { required => 1 }, lang => { required => 1 } },
        paths => [ [ { id => 2, lang => 1 }, "_scripts", "{lang}", "{id}" ] ],
        qs => [ "op_type", "version", "version_type" ],
    },

    'put_template' => {
        body   => { required => 1 },
        doc    => "search-template",
        method => "PUT",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_search", "template", "{id}" ] ],
        qs => [ "op_type", "version", "version_type" ],
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
            "_source",          "_source_exclude",
            "_source_include",  "allow_no_indices",
            "analyze_wildcard", "analyzer",
            "default_operator", "df",
            "expand_wildcards", "explain",
            "fielddata_fields", "fields",
            "from",             "ignore_unavailable",
            "lenient",          "lowercase_expanded_terms",
            "preference",       "q",
            "query_cache",      "routing",
            "scroll",           "search_type",
            "size",             "sort",
            "stats",            "suggest_field",
            "suggest_mode",     "suggest_size",
            "suggest_text",     "terminate_after",
            "timeout",          "track_scores",
            "version",
        ],
    },

    'search_exists' => {
        body   => {},
        doc    => "search-exists",
        method => "POST",
        parts  => { index => { multi => 1 }, type => { multi => 1 } },
        paths  => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_search",
                "exists",
            ],
            [ { type => 1 }, "_all", "{type}", "_search", "exists" ],
            [ { index => 0 }, "{index}", "_search", "exists" ],
            [ {}, "_search", "exists" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "min_score",
            "preference",         "routing",
        ],
    },

    'search_shards' => {
        doc   => "search-shards",
        parts => { index => {}, type => {} },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_search_shards",
            ],
            [ { type => 1 }, "_all", "{type}", "_search_shards" ],
            [ { index => 0 }, "{index}", "_search_shards" ],
            [ {}, "_search_shards" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
            "preference",         "routing",
        ],
    },

    'search_template' => {
        body  => {},
        doc   => "search-template",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_search",
                "template",
            ],
            [ { type => 1 }, "_all", "{type}", "_search", "template" ],
            [ { index => 0 }, "{index}", "_search", "template" ],
            [ {}, "_search", "template" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "preference",
            "routing",            "scroll",
            "search_type",
        ],
    },

    'suggest' => {
        body   => { required => 1 },
        doc    => "search-suggesters",
        method => "POST",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_suggest" ], [ {}, "_suggest" ] ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "preference",
            "routing",
        ],
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
        qs => [
            "dfs",             "field_statistics",
            "fields",          "offsets",
            "parent",          "payloads",
            "positions",       "preference",
            "realtime",        "routing",
            "term_statistics", "version",
            "version_type",
        ],
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
            "refresh",     "retry_on_conflict",
            "routing",     "script",
            "script_id",   "scripted_upsert",
            "timeout",     "timestamp",
            "ttl",         "version",
            "version_type",
        ],
    },

    'cat.aliases' => {
        doc   => "cat-alias",
        parts => { name => { multi => 1 } },
        paths => [
            [ { name => 2 }, "_cat", "aliases", "{name}" ],
            [ {}, "_cat", "aliases" ],
        ],
        qs => [ "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.allocation' => {
        doc   => "cat-allocation",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 2 }, "_cat", "allocation", "{node_id}" ],
            [ {}, "_cat", "allocation" ],
        ],
        qs => [ "bytes", "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.count' => {
        doc   => "cat-count",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "count", "{index}" ],
            [ {}, "_cat", "count" ],
        ],
        qs => [ "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.fielddata' => {
        doc   => "cat-fielddata",
        parts => { fields => { multi => 1 } },
        paths => [
            [ { fields => 2 }, "_cat", "fielddata", "{fields}" ],
            [ {}, "_cat", "fielddata" ],
        ],
        qs => [ "bytes", "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.health' => {
        doc   => "cat-health",
        parts => {},
        paths => [ [ {}, "_cat", "health" ] ],
        qs    => [ "h", "help", "local", "master_timeout", "ts", "v" ],
    },

    'cat.help' => {
        doc   => "cat",
        parts => {},
        paths => [ [ {}, "_cat" ] ],
        qs    => ["help"]
    },

    'cat.indices' => {
        doc   => "cat-indices",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "indices", "{index}" ],
            [ {}, "_cat", "indices" ],
        ],
        qs => [ "bytes", "h", "help", "local", "master_timeout", "pri", "v" ],
    },

    'cat.master' => {
        doc   => "cat-master",
        parts => {},
        paths => [ [ {}, "_cat", "master" ] ],
        qs    => [ "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.nodes' => {
        doc   => "cat-nodes",
        parts => {},
        paths => [ [ {}, "_cat", "nodes" ] ],
        qs    => [ "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.pending_tasks' => {
        doc   => "cat-pending-tasks",
        parts => {},
        paths => [ [ {}, "_cat", "pending_tasks" ] ],
        qs    => [ "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.plugins' => {
        doc   => "cat-plugins",
        parts => {},
        paths => [ [ {}, "_cat", "plugins" ] ],
        qs    => [ "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.recovery' => {
        doc   => "cat-recovery",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "recovery", "{index}" ],
            [ {}, "_cat", "recovery" ],
        ],
        qs => [ "bytes", "h", "help", "master_timeout", "v" ],
    },

    'cat.segments' => {
        doc   => "cat-segments",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "segments", "{index}" ],
            [ {}, "_cat", "segments" ],
        ],
        qs => [ "h", "help", "v" ],
    },

    'cat.shards' => {
        doc   => "cat-shards",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "shards", "{index}" ],
            [ {}, "_cat", "shards" ],
        ],
        qs => [ "h", "help", "local", "master_timeout", "v" ],
    },

    'cat.thread_pool' => {
        doc   => "cat-thread-pool",
        parts => {},
        paths => [ [ {}, "_cat", "thread_pool" ] ],
        qs    => [ "full_id", "h", "help", "local", "master_timeout", "v" ],
    },

    'cluster.get_settings' => {
        doc   => "cluster-update-settings",
        parts => {},
        paths => [ [ {}, "_cluster", "settings" ] ],
        qs => [ "flat_settings", "master_timeout", "timeout" ],
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
        qs => [ "flat_settings", "master_timeout", "timeout" ],
    },

    'cluster.reroute' => {
        body   => {},
        doc    => "cluster-reroute",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_cluster", "reroute" ] ],
        qs => [ "dry_run", "explain", "master_timeout", "metric", "timeout" ],
    },

    'cluster.state' => {
        doc   => "cluster-state",
        parts => { index => { multi => 1 }, metric => { multi => 1 } },
        paths => [
            [   { index => 3, metric => 2 }, "_cluster",
                "state", "{metric}",
                "{index}",
            ],
            [ { index => 3 }, "_cluster", "state", "_all", "{index}" ],
            [ { metric => 2 }, "_cluster", "state", "{metric}" ],
            [ {}, "_cluster", "state" ],
        ],
        qs => [
            "allow_no_indices", "expand_wildcards",
            "flat_settings",    "ignore_unavailable",
            "local",            "master_timeout",
        ],
    },

    'cluster.stats' => {
        doc   => "cluster-stats",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 3 }, "_cluster", "stats", "nodes", "{node_id}" ],
            [ {}, "_cluster", "stats" ],
        ],
        qs => [ "flat_settings", "human" ],
    },

    'indices.analyze' => {
        body  => {},
        doc   => "indices-analyze",
        parts => { index => {} },
        paths =>
            [ [ { index => 0 }, "{index}", "_analyze" ], [ {}, "_analyze" ] ],
        qs => [
            "analyzer", "char_filters", "field", "filters",
            "format",   "prefer_local", "text",  "tokenizer",
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
            "allow_no_indices",   "expand_wildcards",
            "fielddata",          "fields",
            "filter",             "filter_cache",
            "id",                 "id_cache",
            "ignore_unavailable", "query_cache",
            "recycler",
        ],
    },

    'indices.close' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_close" ] ],
        qs     => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "master_timeout",
            "timeout",
        ],
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
        parts  => { index => { multi => 1, required => 1 } },
        paths => [ [ { index => 0 }, "{index}" ] ],
        qs => [ "master_timeout", "timeout" ],
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
        qs => [ "master_timeout", "timeout" ],
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
            name  => { multi => 1, required => 1 },
        },
        paths =>
            [ [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ] ],
        qs => ["master_timeout"],
    },

    'indices.exists' => {
        doc    => "indices-exists",
        method => "HEAD",
        parts  => { index => { multi => 1, required => 1 } },
        paths => [ [ { index => 0 }, "{index}" ] ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
    },

    'indices.exists_alias' => {
        doc    => "indices-aliases",
        method => "HEAD",
        parts  => { index => { multi => 1 }, name => { multi => 1 } },
        paths  => [
            [ { index => 0, name => 2 }, "{index}", "_alias", "{name}" ],
            [ { index => 0 }, "{index}", "_alias" ],
            [ { name  => 1 }, "_alias",  "{name}" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
    },

    'indices.exists_template' => {
        doc    => "indices-templates",
        method => "HEAD",
        parts  => { name => { required => 1 } },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs => [ "local", "master_timeout" ],
    },

    'indices.exists_type' => {
        doc    => "indices-types-exists",
        method => "HEAD",
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1, required => 1 },
        },
        paths => [ [ { index => 0, type => 1 }, "{index}", "{type}" ] ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
    },

    'indices.flush' => {
        doc    => "indices-flush",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_flush" ], [ {}, "_flush" ] ],
        qs => [
            "allow_no_indices", "expand_wildcards",
            "force",            "ignore_unavailable",
            "wait_if_ongoing",
        ],
    },

    'indices.get' => {
        doc   => "indices-get-index",
        parts => {
            feature => { multi => 1 },
            index   => { multi => 1, required => 1 }
        },
        paths => [
            [ { feature => 1, index => 0 }, "{index}", "{feature}" ],
            [ { index => 0 }, "{index}" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
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
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
    },

    'indices.get_aliases' => {
        doc   => "indices-aliases",
        parts => { index => { multi => 1 }, name => { multi => 1 } },
        paths => [
            [ { index => 0, name => 2 }, "{index}", "_aliases", "{name}" ],
            [ { index => 0 }, "{index}",  "_aliases" ],
            [ { name  => 1 }, "_aliases", "{name}" ],
            [ {}, "_aliases" ],
        ],
        qs => [ "local", "timeout" ],
    },

    'indices.get_field_mapping' => {
        doc   => "indices-get-field-mapping",
        parts => {
            field => { multi => 1, required => 1 },
            index => { multi => 1 },
            type  => { multi => 1 },
        },
        paths => [
            [   { field => 4, index => 0, type => 2 }, "{index}",
                "_mapping", "{type}",
                "field",    "{field}",
            ],
            [   { field => 3, index => 0 }, "{index}",
                "_mapping", "field",
                "{field}",
            ],
            [   { field => 3, type => 1 }, "_mapping",
                "{type}", "field",
                "{field}",
            ],
            [ { field => 2 }, "_mapping", "field", "{field}" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "include_defaults",
            "local",
        ],
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
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
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
        qs => [
            "allow_no_indices", "expand_wildcards",
            "flat_settings",    "ignore_unavailable",
            "local",
        ],
    },

    'indices.get_template' => {
        doc   => "indices-templates",
        parts => { name => {} },
        paths =>
            [ [ { name => 1 }, "_template", "{name}" ], [ {}, "_template" ] ],
        qs => [ "flat_settings", "local", "master_timeout" ],
    },

    'indices.get_upgrade' => {
        doc   => "indices-upgrade",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_upgrade" ], [ {}, "_upgrade" ] ],
        qs => [
            "allow_no_indices", "expand_wildcards",
            "human",            "ignore_unavailable",
        ],
    },

    'indices.get_warmer' => {
        doc   => "indices-warmers",
        parts => {
            index => { multi => 1 },
            name  => { multi => 1 },
            type  => { multi => 1 }
        },
        paths => [
            [   { index => 0, name => 3, type => 1 },
                "{index}", "{type}", "_warmer", "{name}",
            ],
            [   { name => 3, type => 1 }, "_all",
                "{type}", "_warmer",
                "{name}"
            ],
            [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ],
            [ { index => 0 }, "{index}", "_warmer" ],
            [ { name  => 1 }, "_warmer", "{name}" ],
            [ {}, "_warmer" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
    },

    'indices.open' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_open" ] ],
        qs     => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "master_timeout",
            "timeout",
        ],
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
            "allow_no_indices",     "expand_wildcards",
            "flush",                "force",
            "ignore_unavailable",   "max_num_segments",
            "only_expunge_deletes", "wait_for_merge",
        ],
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
        qs => [ "master_timeout", "timeout" ],
    },

    'indices.put_mapping' => {
        body   => { required => 1 },
        doc    => "indices-put-mapping",
        method => "PUT",
        parts => { index => { multi => 1 }, type => { required => 1 } },
        paths => [
            [ { index => 0, type => 2 }, "{index}", "_mapping", "{type}" ],
            [ { type => 1 }, "_mapping", "{type}" ],
        ],
        qs => [
            "allow_no_indices", "expand_wildcards",
            "ignore_conflicts", "ignore_unavailable",
            "master_timeout",   "timeout",
        ],
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
        qs => [
            "allow_no_indices", "expand_wildcards",
            "flat_settings",    "ignore_unavailable",
            "master_timeout",
        ],
    },

    'indices.put_template' => {
        body   => { required => 1 },
        doc    => "indices-templates",
        method => "PUT",
        parts => { name => { required => 1 } },
        paths => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs => [
            "create",         "flat_settings",
            "master_timeout", "order",
            "timeout"
        ],
    },

    'indices.put_warmer' => {
        body   => { required => 1 },
        doc    => "indices-warmers",
        method => "PUT",
        parts  => {
            index => { multi    => 1 },
            name  => { required => 1 },
            type  => { multi    => 1 },
        },
        paths => [
            [   { index => 0, name => 3, type => 1 },
                "{index}", "{type}", "_warmer", "{name}",
            ],
            [   { name => 3, type => 1 }, "_all",
                "{type}", "_warmer",
                "{name}"
            ],
            [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ],
            [ { name => 1 }, "_warmer", "{name}" ],
        ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "master_timeout",
        ],
    },

    'indices.recovery' => {
        doc   => "indices-recovery",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_recovery" ],
            [ {}, "_recovery" ]
        ],
        qs => [ "active_only", "detailed", "human" ],
    },

    'indices.refresh' => {
        doc    => "indices-refresh",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_refresh" ], [ {}, "_refresh" ] ],
        qs => [
            "allow_no_indices", "expand_wildcards",
            "force",            "ignore_unavailable",
        ],
    },

    'indices.segments' => {
        doc   => "indices-segments",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_segments" ],
            [ {}, "_segments" ]
        ],
        qs => [
            "allow_no_indices", "expand_wildcards",
            "human",            "ignore_unavailable",
        ],
    },

    'indices.stats' => {
        doc   => "indices-stats",
        parts => { index => { multi => 1 }, metric => { multi => 1 } },
        paths => [
            [ { index => 0, metric => 2 }, "{index}", "_stats", "{metric}" ],
            [ { index  => 0 }, "{index}", "_stats" ],
            [ { metric => 1 }, "_stats",  "{metric}" ],
            [ {}, "_stats" ],
        ],
        qs => [
            "completion_fields", "fielddata_fields",
            "fields",            "groups",
            "human",             "level",
            "types",
        ],
    },

    'indices.update_aliases' => {
        body   => { required => 1 },
        doc    => "indices-aliases",
        method => "POST",
        parts  => {},
        paths => [ [ {}, "_aliases" ] ],
        qs => [ "master_timeout", "timeout" ],
    },

    'indices.upgrade' => {
        doc    => "indices-upgrade",
        method => "POST",
        parts  => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_upgrade" ], [ {}, "_upgrade" ] ],
        qs => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "only_ancient_segments",
            "wait_for_completion",
        ],
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
        qs => [
            "allow_no_indices", "expand_wildcards",
            "explain",          "ignore_unavailable",
            "q",
        ],
    },

    'nodes.hot_threads' => {
        doc   => "cluster-nodes-hot-threads",
        parts => { node_id => { multi => 1 } },
        paths => [
            [ { node_id => 1 }, "_nodes", "{node_id}", "hot_threads" ],
            [ {}, "_nodes", "hot_threads" ],
        ],
        qs => [
            "ignore_idle_threads", "interval",
            "snapshots",           "threads",
            "type",
        ],
    },

    'nodes.info' => {
        doc   => "cluster-nodes-info",
        parts => { metric => { multi => 1 }, node_id => { multi => 1 } },
        paths => [
            [   { metric => 2, node_id => 1 }, "_nodes",
                "{node_id}", "{metric}",
            ],
            [ { metric => 2 }, "_nodes", "_all", "{metric}" ],
            [ { node_id => 1 }, "_nodes", "{node_id}" ],
            [ {}, "_nodes" ],
        ],
        qs => [ "flat_settings", "human" ],
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
            [   { index_metric => 4, node_id => 1 },
                "_nodes", "{node_id}", "stats", "_all", "{index_metric}",
            ],
            [   { index_metric => 3, metric => 2 }, "_nodes",
                "stats", "{metric}",
                "{index_metric}",
            ],
            [   { index_metric => 3 }, "_nodes",
                "stats", "_all",
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
        qs => [
            "completion_fields", "fielddata_fields",
            "fields",            "groups",
            "human",             "level",
            "types",
        ],
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
        qs => [ "master_timeout", "wait_for_completion" ],
    },

    'snapshot.create_repository' => {
        body   => { required => 1 },
        doc    => "modules-snapshots",
        method => "PUT",
        parts => { repository => { required => 1 } },
        paths => [ [ { repository => 1 }, "_snapshot", "{repository}" ] ],
        qs => [ "master_timeout", "timeout", "verify" ],
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
        qs => ["master_timeout"],
    },

    'snapshot.delete_repository' => {
        doc    => "modules-snapshots",
        method => "DELETE",
        parts  => { repository => { multi => 1, required => 1 } },
        paths  => [ [ { repository => 1 }, "_snapshot", "{repository}" ] ],
        qs => [ "master_timeout", "timeout" ],
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
        qs => ["master_timeout"],
    },

    'snapshot.get_repository' => {
        doc   => "modules-snapshots",
        parts => { repository => { multi => 1 } },
        paths => [
            [ { repository => 1 }, "_snapshot", "{repository}" ],
            [ {}, "_snapshot" ],
        ],
        qs => [ "local", "master_timeout" ],
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
        qs => [ "master_timeout", "wait_for_completion" ],
    },

    'snapshot.status' => {
        doc   => "modules-snapshots",
        parts => { repository => {}, snapshot => { multi => 1 } },
        paths => [
            [   { repository => 1, snapshot => 2 }, "_snapshot",
                "{repository}", "{snapshot}",
                "_status",
            ],
            [   { snapshot => 2 }, "_snapshot",
                "_all", "{snapshot}",
                "_status"
            ],
            [ { repository => 1 }, "_snapshot", "{repository}", "_status" ],
            [ {}, "_snapshot", "_status" ],
        ],
        qs => ["master_timeout"],
    },

    'snapshot.verify_repository' => {
        doc    => "modules-snapshots",
        method => "POST",
        parts  => { repository => { required => 1 } },
        paths  => [
            [ { repository => 1 }, "_snapshot", "{repository}", "_verify" ],
        ],
        qs => [ "master_timeout", "timeout" ],
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
is the definition for the L<Search::Elasticsearch::Client::2_0::Direct/index()> method:

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
            'refresh',     'routing',     'timeout',
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

L<Search::Elasticsearch::Client::1_0::Direct>

=item *

L<Search::Elasticsearch::Client::0_90::Direct>

=back
