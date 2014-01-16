package Elasticsearch::Role::API;

use Moo::Role;

use Elasticsearch::Util qw(throw);
use Elasticsearch::Util::API::QS qw(qs_init);
use Elasticsearch::Util::API::Path qw(path_init);
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

    "bulk" => {
        body   => {},
        doc    => "docs-bulk",
        method => "POST",
        path   => "{index-when-type}/{type|blank}/_bulk",
        qs => [ "consistency", "refresh", "replication", "timeout", "type" ],
        serialize => "bulk",
    },

    "clear_scroll" => {
        doc    => "search-request-search-type",
        method => "DELETE",
        path   => "_search/scroll/{scroll_ids}",
    },

    "count" => {
        body => {},
        doc  => "search-count",
        path => "{indices|all-type}/{types}/_count",
        qs   => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "min_score",
            "preference",         "routing",
            "source",
        ],
    },

    "delete" => {
        doc    => "docs-delete",
        method => "DELETE",
        path   => "{index}/{type}/{id}",
        qs     => [
            "consistency", "parent",  "replication", "refresh",
            "routing",     "timeout", "version",     "version_type",
        ],
    },

    "delete_by_query" => {
        body   => { required => 1 },
        doc    => "docs-delete-by-query",
        method => "DELETE",
        path   => "{indices|all-type}/{types}/_query",
        qs     => [
            "analyzer",           "consistency",
            "default_operator",   "df",
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "q",
            "replication",        "routing",
            "source",             "timeout",
        ],
    },

    "exists" => {
        doc    => "docs-get",
        method => "HEAD",
        path   => "{index}/{type|all}/{id}",
        qs => [ "parent", "preference", "realtime", "refresh", "routing" ],
    },

    "explain" => {
        body => { required => 1 },

        doc  => "search-explain",
        path => "{index}/{type}/{id}/_explain",
        qs   => [
            "analyze_wildcard",         "analyzer",
            "default_operator",         "df",
            "fields",                   "lenient",
            "lowercase_expanded_terms", "parent",
            "preference",               "q",
            "routing",                  "source",
            "_source",                  "_source_include",
            "_source_exclude",
        ],
    },

    "get" => {
        doc  => "docs-get",
        path => "{index}/{type|all}/{id}",
        qs   => [
            "fields",          "parent",
            "preference",      "realtime",
            "refresh",         "routing",
            "_source",         "_source_include",
            "_source_exclude", "version",
            "version_type",
        ],
    },

    "get_source" => {
        doc  => "docs-get",
        path => "{index}/{type|all}/{id}/_source",
        qs   => [
            "parent",          "preference",
            "realtime",        "refresh",
            "routing",         "_source",
            "_source_include", "_source_exclude",
            "version",         "version_type",
        ],
    },

    "index" => {
        body   => { required => 1 },
        doc    => "docs-index_",
        method => "PUT",
        path   => "{index}/{type}/{id|blank}",
        qs     => [
            "consistency", "op_type", "parent",  "refresh",
            "replication", "routing", "timeout", "timestamp",
            "ttl",         "version", "version_type",
        ],
    },

    "info" => { doc => "index", path => "" },

    "mget" => {
        body => { required => 1, },

        doc  => "docs-multi-get",
        path => "{index-when-type}/{type|blank}/_mget",
        qs   => [
            "fields",   "preference",
            "realtime", "refresh",
            "_source",  "_source_include",
            "_source_exclude",
        ],
    },

    "mlt" => {
        body => {},
        doc  => "search-more-like-this",
        path => "{index}/{type|all}/{id}/_mlt",
        qs   => [
            "boost_terms",            "max_doc_freq",
            "max_query_terms",        "max_word_length",
            "min_doc_freq",           "min_term_freq",
            "min_word_length",        "mlt_fields",
            "percent_terms_to_match", "routing",
            "search_from",            "search_indices",
            "search_query_hint",      "search_scroll",
            "search_size",            "search_source",
            "search_type",            "search_types",
            "stop_words",
        ],
    },

    "msearch" => {
        body => { required => 1, },

        doc       => "search-multi-search",
        path      => "{indices|all-type}/{types}/_msearch",
        qs        => ["search_type"],
        serialize => "bulk",
    },

    "percolate" => {
        body => { required => 1, },

        doc  => "search-percolate",
        path => "{index}/{type}/_percolate",
        qs   => ["prefer_local"],
    },

    "ping" => { doc => "index", method => "HEAD", path => "" },

    "scroll" => {
        body => {},
        doc  => "search-request-scroll",
        path => "_search/scroll",
        qs   => [ "scroll", "scroll_id" ],
    },

    "search" => {
        body => {},
        doc  => "search-search",
        path => "{indices|all-type}/{types}/_search",
        qs   => [
            "analyze_wildcard", "analyzer",
            "default_operator", "df",
            "explain",          "fields",
            "from",             "allow_no_indices",
            "expand_wildcards", "ignore_unavailable",
            "lenient",          "lowercase_expanded_terms",
            "preference",       "q",
            "routing",          "scroll",
            "search_type",      "size",
            "sort",             "source",
            "_source",          "_source_include",
            "_source_exclude",  "stats",
            "suggest_field",    "suggest_mode",
            "suggest_size",     "suggest_text",
            "timeout",          "version",
        ],
    },

    "suggest" => {
        body => {},
        doc  => "search-suggesters",
        path => "{indices|all-type}/{types}/_suggest",
        qs   => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "preference",
            "routing",            "source",
        ],
    },

    "update" => {
        body   => {},
        doc    => "docs-update",
        method => "POST",
        path   => "{index}/{type}/{id}/_update",
        qs     => [
            "consistency", "fields",
            "lang",        "parent",
            "realtime",    "refresh",
            "replication", "retry_on_conflict",
            "routing",     "script",
            "timeout",     "timestamp",
            "ttl",         "version",
            "version_type",
        ],
    },

    # Cat

    "cat.aliases" => {
        doc  => "cat-aliases",
        path => "/_cat/aliases/{names|blank}",
        qs   => [ "local", "master_timeout", "h", "help", "v" ],
    },

    "cat.allocation" => {
        doc  => "cat-allocation",
        path => "/_cat/allocation/{nodes}",
        qs   => [ "bytes", "local", "master_timeout", "h", "help", "v" ],
    },

    "cat.count" => {
        doc  => "cat-count",
        path => "/_cat/count/{index}",
        qs   => [ "local", "master_timeout", "h", "help", "pri", "v" ],
    },

    "cat.health" => {
        doc  => "cat-health",
        path => "/_cat/health",
        qs   => [ "local", "master_timeout", "h", "help", "ts", "v" ],
    },

    "cat.help" => { doc => "cat", path => "/_cat", qs => ["help"] },

    "cat.indices" => {
        doc  => "cat-indices",
        path => "/_cat/indices/{index}",
        qs => [ "bytes", "local", "master_timeout", "h", "help", "pri", "v" ],
    },

    "cat.master" => {
        doc  => "cat-master",
        path => "/_cat/master",
        qs   => [ "local", "master_timeout", "h", "help", "v" ],
    },

    "cat.nodes" => {
        doc  => "cat-nodes",
        path => "/_cat/nodes",
        qs   => [ "local", "master_timeout", "h", "help", "v" ],
    },

    "cat.pending_tasks" => {
        doc  => "cat-pending-tasks",
        path => "/_cat/pending_tasks",
        qs   => [ "local", "master_timeout", "h", "help", "v" ],
    },

    "cat.recovery" => {
        doc  => "cat-recovery",
        path => "/_cat/recovery/{index}",
        qs => [ "bytes", "local", "master_timeout", "h", "help", "pri", "v" ],
    },

    "cat.shards" => {
        doc  => "cat-shards",
        path => "/_cat/shards/{index}",
        qs   => [ "local", "master_timeout", "h", "help", "v" ],
    },

    # Cluster

    "cluster.get_settings" => {
        doc  => "cluster-update-settings",
        path => "_cluster/settings",
        qs   => [ "flat_settings", "master_timeout", "timeout" ],
    },

    "cluster.health" => {
        doc  => "cluster-health",
        path => "_cluster/health",
        qs   => [
            "level",                      "local",
            "master_timeout",             "timeout",
            "wait_for_active_shards",     "wait_for_nodes",
            "wait_for_relocating_shards", "wait_for_status",
        ],
    },

    "cluster.pending_tasks" => {
        doc  => "cluster-pending",
        path => "_cluster/pending_tasks",
        qs   => []
    },

    "cluster.put_settings" => {
        body   => { required => 1 },
        doc    => "cluster-update-settings",
        method => "PUT",
        path   => "_cluster/settings",
        qs     => ["flat_settings"],
    },

    "cluster.reroute" => {
        body   => {},
        doc    => "cluster-reroute",
        method => "POST",
        path   => "_cluster/reroute",
        qs => [ "dry_run", "filter_metadata", "master_timeout", "timeout" ],
    },

    "cluster.state" => {
        doc  => "cluster-state",
        path => "_cluster/state/{metrics}/{indices}",
        qs   => [ "flat_settings", "local", "master_timeout" ],
    },

    "cluster.stats" => {
        doc  => "cluster-stats",
        path => "_cluster/stats/nodes/{nodes}",
        qs   => [ "flat_settings", "human" ],
    },

    # Indices

    "indices.analyze" => {
        body   => {},
        doc    => "indices-analyze",
        method => "POST",
        path   => "{index|blank}/_analyze",
        qs     => [
            "analyzer", "field",        "filters", "format",
            "index",    "prefer_local", "text",    "tokenizer",
        ],
    },

    "indices.clear_cache" => {
        doc    => "indices-clearcache",
        method => "POST",
        path   => "{indices}/_cache/clear",
        qs     => [
            "fielddata",          "fields",
            "filter",             "filter_cache",
            "filter_keys",        "id",
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "index",
            "recycler",
        ],
    },

    "indices.close" => {
        doc    => "indices-open-close",
        method => "POST",
        path   => "{req_indices}/_close",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.create" => {
        body   => {},
        doc    => "indices-create-index",
        method => "PUT",
        path   => "{index}",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.delete" => {
        doc    => "indices-delete-index",
        method => "DELETE",
        path   => "{req_indices}",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.delete_alias" => {
        doc    => "indices-aliases",
        method => "DELETE",
        path   => "{req_indices}/_alias/{req_names}",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.delete_mapping" => {
        doc    => "indices-delete-mapping",
        method => "DELETE",
        path   => "{req_indices}/_mapping/{req_types}",
        qs     => ["master_timeout"],
    },

    "indices.delete_template" => {
        doc    => "indices-templates",
        method => "DELETE",
        path   => "_template/{name}",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.delete_warmer" => {
        doc    => "indices-warmers",
        method => "DELETE",
        path   => "{req_indices}/_warmer/{req_names}",
        qs     => ["master_timeout"],
    },

    "indices.exists" => {
        doc    => "indices-exists",
        method => "HEAD",
        path   => "{req_indices}"
    },

    "indices.exists_alias" => {
        doc    => "indices-aliases",
        method => "HEAD",
        path   => "{indices}/_alias/{names|blank}",
        qs =>
            [ "allow_no_indices", "expand_wildcards", "ignore_unavailable" ],
    },

    "indices.exists_template" => {
        doc    => "indices-templates",
        method => "HEAD",
        path   => "_template/{name}",
    },

    "indices.exists_type" => {
        doc    => "indices-types-exists",
        method => "HEAD",
        path   => "{indices|all}/{req_types}",
        qs =>
            [ "allow_no_indices", "expand_wildcards", "ignore_unavailable" ],
    },

    "indices.flush" => {
        doc    => "indices-flush",
        method => "POST",
        path   => "{indices}/_flush",
        qs     => [
            "force",            "full",
            "allow_no_indices", "expand_wildcards",
            "ignore_unavailable",
        ],
    },

    "indices.get_alias" => {
        doc  => "indices-aliases",
        path => "{indices}/_alias/{names|blank}",
        qs =>
            [ "allow_no_indices", "expand_wildcards", "ignore_unavailable" ],
    },

    "indices.get_aliases" => {
        doc  => "indices-aliases",
        path => "{indices}/_aliases/{names|blank}",
        qs   => ["timeout"],
    },

    "indices.get_field_mapping" => {
        doc  => "indices-get-field-mapping",
        path => "{indices}/_mapping/{types}/field/{field}",
        qs   => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "include_defaults",
        ],
    },

    "indices.get_mapping" => {
        doc  => "indices-get-mapping",
        path => "{indices}/_mapping/{types}",
        qs   => [
            "allow_no_indices",   "expand_wildcards",
            "ignore_unavailable", "local",
        ],
    },

    "indices.get_settings" => {
        doc  => "indices-get-settings",
        path => "{indices}/_settings/{names|blank}",
        qs   => ["flat_settings"],
    },

    "indices.get_template" => {
        doc  => "indices-templates",
        path => "_template/{name|blank}",
        qs   => ["flat_settings"],
    },

    "indices.get_warmer" => {
        doc  => "indices-warmers",
        path => "{indices|all}/_warmer/{names|blank}",
    },

    "indices.open" => {
        doc    => "indices-open-close",
        method => "POST",
        path   => "{indices|all}/_open",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.optimize" => {
        doc    => "indices-optimize",
        method => "POST",
        path   => "{indices}/_optimize",
        qs     => [
            "flush",            "allow_no_indices",
            "expand_wildcards", "ignore_unavailable",
            "max_num_segments", "only_expunge_deletes",
            "wait_for_merge",
        ],
    },

    "indices.put_alias" => {
        body   => {},
        doc    => "indices-aliases",
        method => "PUT",
        path   => "{indices}/_alias/{name}",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.put_mapping" => {
        body   => { required => 1 },
        doc    => "indices-put-mapping",
        method => "PUT",
        path   => "{indices}/_mapping/{type}",
        qs => [ "ignore_conflicts", "timeout", "master_timeout" ],
    },

    "indices.put_settings" => {
        body   => { required => 1 },
        doc    => "indices-update-settings",
        method => "PUT",
        path   => "{indices}/_settings",
        qs => [ "master_timeout", "flat_settings" ],
    },

    "indices.put_template" => {
        body   => { required => 1 },
        doc    => "indices-templates",
        method => "PUT",
        path   => "_template/{name}",
        qs => [ "flat_settings", "order", "timeout", "master_timeout" ],
    },

    "indices.put_warmer" => {
        body => { required => 1, },

        doc    => "indices-warmers",
        method => "PUT",
        path   => "{indices}/_warmer/{name}",
        qs     => ["master_timeout"],
    },

    "indices.refresh" => {
        doc    => "indices-refresh",
        method => "POST",
        path   => "{indices}/_refresh",
        qs     => [
            "allow_no_indices", "expand_wildcards",
            "force",            "ignore_unavailable",
        ],
    },

    "indices.segments" => {
        doc  => "indices-segments",
        path => "{indices}/_segments",
        qs   => [
            "allow_no_indices", "expand_wildcards",
            "human",            "ignore_unavailable",
        ],
    },

    "indices.snapshot_index" => {
        docs   => "indices-gateway-snapshot",
        method => "POST",
        params =>
            [ "allow_no_indices", "expand_wildcards", "ignore_unavailable" ],
        path => "{indices}/_gateway/snapshot",
    },

    "indices.stats" => {
        doc  => "indices-stats",
        path => "{indices}/_stats/{metrics}",
        qs   => [
            "completion_fields", "fielddata_fields",
            "fields",            "groups",
            "human",             "level",
            "types",
        ],
    },

    "indices.status" => {
        doc  => "indices-status",
        path => "{indices}/_status",
        qs   => [
            "allow_no_indices", "expand_wildcards",
            "human",            "ignore_unavailable",
            "recovery",         "snapshot",
        ],
    },

    "indices.update_aliases" => {
        body => { required => 1 },

        doc    => "indices-aliases",
        method => "POST",
        path   => "_aliases",
        qs     => [ "timeout", "master_timeout" ],
    },

    "indices.validate_query" => {
        body => {},
        doc  => "search-validate",
        path => "{indices|all-type}/{types}/_validate/query",
        qs   => [
            "explain",          "allow_no_indices",
            "expand_wildcards", "ignore_unavailable",
            "q",                "source",
        ],
    },

    # Nodes

    "nodes.hot_threads" => {
        doc  => "cluster-nodes-hot-threads",
        path => "_nodes/{nodes|blank}/hot_threads",
        qs   => [ "interval", "snapshots", "threads", "type" ],
    },

    "nodes.info" => {
        doc  => "cluster-nodes-info",
        path => "_nodes/{nodes}/{metrics}",
        qs   => [ "flat_settings", "human" ],
    },

    "nodes.shutdown" => {
        doc    => "cluster-nodes-shutdown",
        method => "POST",
        path   => "_cluster/nodes/{nodes|blank}/_shutdown",
        qs     => [ "delay", "exit" ],
    },

    "nodes.stats" => {
        doc  => "cluster-nodes-stats",
        path => "_nodes/{nodes}/stats/{metrics}/{index_metrics}",
        qs   => [
            "completion_fields", "fielddata_fields",
            "fields",            "groups",
            "human",             "level",
            "types",
        ],
    },

    # Snapshot and restore

    "snapshot.create" => {
        body   => {},
        doc    => "module-snapshots",
        method => "PUT",
        path   => "_snapshot/{repo}/{snapshot}",
        qs     => [ "master_timeout", "wait_for_completion" ],
    },

    "snapshot.delete" => {
        doc    => "module-snapshots",
        method => "DELETE",
        path   => "_snapshot/{repo}/{req_snapshots}",
        qs     => ["master_timeout"],
    },

    "snapshot.delete_repository" => {
        doc    => "module-snapshots",
        method => "DELETE",
        path   => "_snapshot/{req_repos}",
        qs     => [ "master_timeout", "timeout" ],
    },

    "snapshot.get" => {
        doc  => "module-snapshots",
        path => "_snapshot/{req_repos}/{snapshots}",
        qs   => ["master_timeout"],
    },

    "snapshot.get_repository" => {
        doc  => "module-snapshots",
        path => "_snapshot/{repos}",
        qs   => ["master_timeout"],
    },

    "snapshot.put_repository" => {
        body   => { required => 1 },
        doc    => "module-snapshots",
        method => "PUT",
        path   => "_snapshot/{repo}",
        qs => [ "master_timeout", "timeout" ],
    },

    "snapshot.restore" => {
        body => {},
        doc  => "module-snapshots",
        path => "_snapshot/{repo}/{snapshot}",
        qs   => [ "master_timeout", "wait_for_completion" ],
    },

);

for ( values %API ) {
    $_->{qs_handlers}  = qs_init( @{ $_->{qs} } );
    $_->{path_handler} = path_init( $_->{path} );
}

1;

__END__

# ABSTRACT: This class contains the spec for the Elasticsearch APIs

=head1 DESCRIPTION

All of the Elasticsearch APIs are defined in this role. The example given below
is the definition for the L<Elasticsearch::Client::Direct/index()> method:

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


These definitions can be used by different L<Elasticsearch::Role::Client>
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

L<Elasticsearch::Util::API::Path>

=item *

L<Elasticsearch::Util::API::QS>

=item *

L<Elasticsearch::Client::Direct>

=back
