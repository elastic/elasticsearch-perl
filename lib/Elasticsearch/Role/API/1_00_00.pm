package Elasticsearch::Role::API::1_00_00;

use Moo::Role;
with 'Elasticsearch::Role::API';
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use Elasticsearch::Util::API::QS qw(qs_init);

our %API;

#===================================
sub api {
#===================================
    my $name = $_[1] || return \%API;
    return $API{$name}
        || throw( "Internal", "Unknown api name ($name)" );
}

#===================================
%API = (
#===================================
    'bulk' => {
        body => {
            desc => 'The operation definition and data (action-data pairs), '
                . 'separated by newlines'
        },
        doc       => '/api/bulk/',
        method    => 'POST',
        path      => '{index}/{type}/_bulk',
        serialize => 'bulk',
        qs        => qs_init qw(consistency refresh replication type),
    },

    'count' => {
        body => { desc => 'A query to restrict the results (optional)' },
        doc  => '/api/count/',
        path => '{indices|all-type}/{types}/_count',
        qs => qs_init qw(ignore_indices min_score preference routing source),
    },

    'delete' => {
        doc    => '/api/delete/',
        method => 'DELETE',
        path   => '{index}/{type}/{id}',
        qs     => qs_init qw(
            consistency ignore_missing parent replication
            refresh routing timeout version version_type),
    },

    'delete_by_query' => {
        body => { desc => 'A query to restrict the operation' },
        doc    => '/api/delete-by-query/',
        method => 'DELETE',
        path   => '{indices|all-type}/{types}/_query',
        qs     => qs_init qw(
            analyzer consistency default_operator df ignore_indices q
            replication routing source timeout),
    },

    'exists' => {
        doc    => '/api/get/',
        method => 'HEAD',
        path   => '{index}/{type|all}/{id}',
        qs     => qs_init qw(parent preference realtime refresh routing),
    },

    'explain' => {
        body => {
            desc     => 'The query definition using the Query DSL',
            required => 1
        },
        doc  => '/api/explain/',
        path => '{indices|all-type}/{types}/_explain',
        qs   => qs_init qw(
            analyze_wildcard analyzer default_operator
            df fields lenient lowercase_expanded_terms
            parent preference q routing source),
    },

    'get' => {
        doc  => '/api/get/',
        path => '{index}/{type|all}/{id}',
        qs   => qs_init qw(
            fields ignore_missing parent preference
            realtime refresh routing),
    },

    'get_source' => {
        doc  => '/api/get/',
        path => '{index}/{type|all}/{id}/_source',
        qs   => qs_init qw(
            ignore_missing parent preference
            realtime refresh routing),
    },

    'index' => {
        body => {
            desc     => 'The document',
            required => 1
        },
        doc    => '/api/index_/',
        method => 'PUT',
        path   => '{index}/{type}/{id|blank}',
        qs     => qs_init qw(
            consistency op_type parent percolate
            refresh replication routing timeout
            timestamp ttl version version_type),
    },

    'info' => {
        doc  => '/',
        path => '/',
    },

    'mget' => {
        body => {
            required => 1,
            desc     => 'Document identifiers; can be either'
                . ' `docs` (containing full document information) or '
                . '`ids` (when index and type is provided in the URL.'
        },
        doc  => '/api/multi-get/',
        path => '{index|blank}/{type|blank}/_mget',
        qs   => qs_init qw(fields preference realtime refresh),
    },

    'mlt' => {
        body => { desc => 'A specific search request definition' },
        doc  => '/api/more-like-this/',
        path => '{index}/{type|all}/{id}_mlt',
        qs   => qs_init qw(
            boost_terms max_doc_freq max_query_terms
            max_word_len min_doc_freq min_term_freq
            min_word_len mlt_fields percent_terms_to_match
            routing search_from search_indices
            search_query_hint search_scroll search_size
            search_source search_type search_types stop_words),
    },

    'msearch' => {
        body => {
            required => 1,
            desc     => 'The request definitions (metadata-search '
                . 'request definition pairs), separated by newlines'
        },
        doc       => '/api/multi-search/',
        path      => '{indices|all-type}/{types}/_msearch',
        serialize => 'bulk',
        qs        => qs_init qw(search_type),
    },

    'percolate' => {
        body => {
            required => 1,
            desc     => 'The document (`doc`) to percolate against '
                . 'registered queries; optionally also a '
                . '`query` to limit the percolation to '
                . 'specific registered queries'
        },
        doc  => '/api/percolate/',
        path => '{index}/{type}/_percolate',
        qs   => qs_init qw(prefer_local),
    },

    'ping' => {
        doc    => '/',
        method => 'HEAD',
        path   => '/',
    },

    'scroll' => {
        body => {
            desc => 'The scroll ID if not passed by URL or query parameter.'
        },
        doc  => '/api/search/scroll/',
        path => '_search/scroll',
        qs   => qs_init qw(scroll scroll_id),
    },

    'search' => {
        body => { desc => 'The search definition using the Query DSL' },
        doc  => '/api/search/',
        path => '{indices|all-type}/{types}/_search',
        qs   => qs_init qw(
            analyze_wildcard analyzer default_operator
            df explain fields from ignore_indices indices_boost
            lenient lowercase_expanded_terms preference
            q routing scroll search_type size sort source
            stats suggest_field suggest_mode suggest_size
            suggest_text timeout version),
    },

    'suggest' => {
        body => { desc => 'The request definition' },
        doc  => '/api/search/suggest/',
        path => '{indices|all-type}/{types}/_suggest',
        qs   => qs_init qw(ignore_indices preference routing source),
    },

    'update' => {
        body => {
            desc => 'The request definition using either '
                . '`script` or partial `doc`'
        },
        doc    => '/api/update/',
        method => 'POST',
        path   => '{index}/{type}/{id}/_update',
        qs     => qs_init qw(
            consistency fields ignore_missing lang parent percolate
            realtime refresh replication retry_on_conflict routing
            script timeout timestamp ttl version version_type),
    },

    'cluster.get_settings' => {
        doc  => '/api/admin-cluster-update-settings/',
        path => '_cluster/settings',
    },

    'cluster.health' => {
        doc  => '/api/admin-cluster-health/',
        path => '_cluster/health',
        qs   => qs_init qw(
            level local master_timeout timeout
            wait_for_active_shards wait_for_nodes
            wait_for_relocating_shards wait_for_status),
    },

    'cluster.hot_threads' => {
        doc  => '/api/admin-cluster-nodes-hot-threads/',
        path => '_nodes/{nodes}/hot_threads',
        qs   => qs_init qw(interval snapshots threads type),
    },

    'cluster.node_info' => {
        doc  => '/api/admin-cluster-nodes-info/',
        path => '_nodes/{nodes}',
        qs   => qs_init qw(
            all clear http jvm network os plugin
            process settings timeout thread_pool transport),
    },

    'cluster.shutdown' => {
        doc    => '/api/admin-cluster-nodes-shutdown/',
        method => 'POST',
        path   => '_cluster/_nodes/{nodes}/_shutdown',
        qs     => qs_init qw(delay exit),
    },

    'cluster.node_stats' => {
        doc => '/api/admin-cluster-nodes-stats/',

        ###
        qs => qs_init qw(
            all clear fields fs http indices jvm
            network os process thread_pool transport),
    },

    'cluster.put_settings' => {
        body => {
            desc => 'The settings to be updated. Can be either '
                . '`transient` or `persistent`.'
        },
        doc    => '/api/admin-cluster-update-settings/',
        method => 'PUT',
        path   => '_cluster/settings',
    },

    'cluster.reroute' => {
        body => {
            desc => 'The definition of `commands` to perform '
                . '(`move`, `cancel`, `allocate`)'
        },
        doc    => '/api/admin-cluster-reroute/',
        method => 'POST',
        path   => '_cluster/reroute',
        qs     => qs_init qw(dry_run filter_metadata),
    },

    'cluster.state' => {
        doc  => '/api/admin-cluster-state/',
        path => '_cluster/state',
        qs   => qs_init qw(
            filter_blocks filter_index_templates
            filter_indices filter_metadata filter_nodes
            filter_routing_table local master_timeout),
    },

    'indices.analyze' => {
        body =>
            { desc => 'The text on which the analysis should be performed' },
        doc    => '/api/admin-indices-analyze/',
        method => 'POST',
        path   => '{index|blank}/_analyze',
        qs     => qs_init qw(
            analyzer field filters format
            index prefer_local text tokenizer),
    },

    'indices.clear_cache' => {
        doc    => '/api/admin-indices-clearcache/',
        method => 'POST',
        path   => '{indices}/_cache/clear',
        qs     => qs_init qw(
            fielddata fields filter
            filter_cache filter_keys id
            ignore_indices index recycler),
    },

    'indices.close' => {
        doc    => '/api/admin-indices-open-close/',
        method => 'POST',
        path   => '{index}/_close',
        qs     => qs_init qw(timeout),
    },

    'indices.create' => {
        body => {
            desc => 'The configuration for the index '
                . '(`settings` and `mappings`)'
        },
        doc    => '/api/admin-indices-create-index/',
        method => 'PUT',
        path   => '{index}',
        qs     => qs_init qw(timeout),
    },

    'indices.delete' => {
        doc    => '/api/admin-indices-delete-index/',
        method => 'DELETE',
        path   => '{indices}',
        qs     => qs_init qw(ignore_missing timeout),
    },

    'indices.delete_alias' => {
        doc    => '/api/admin-indices-aliases/',
        method => 'DELETE',
        path   => '{index}/_alias/{alias}',
        qs     => qs_init qw(timeout),
    },

    'indices.delete_mapping' => {
        doc    => '/api/admin-indices-delete-mapping/',
        method => 'DELETE',
        path   => '{indices|all}/{type}',
    },

    'indices.delete_template' => {
        doc    => '/api/admin-indices-templates/',
        method => 'DELETE',
        path   => '_template/{template}',
        qs     => qs_init qw(timeout),
    },

    'indices.delete_warmer' => {
        doc    => '/api/admin-indices-warmers/',
        method => 'DELETE',
        path   => '_warmer/{warmer}',
    },

    'indices.exists' => {
        doc    => '/api/admin-indices-indices-exists/',
        method => 'HEAD',
        path   => '{req_indices}',
    },

    'indices.exists_alias' => {
        doc    => '/api/admin-indices-aliases/',
        method => 'HEAD',
        path   => '{indices}/_alias/{aliases}',
        qs     => qs_init qw(ignore_indices),
    },

    'indices.exists_type' => {
        doc    => '/api/admin-indices-types-exists/',
        method => 'HEAD',
        path   => '{indices|all}/{req_types}',
        qs     => qs_init qw(ignore_indices),
    },

    'indices.flush' => {
        doc    => '/api/admin-indices-flush/',
        method => 'POST',
        path   => '{indices}/_flush',
        qs     => qs_init qw(force full ignore_indices refresh),
    },

    'indices.get_alias' => {
        doc  => '/api/admin-indices-aliases/',
        path => '{indices}/_aliases',
        qs   => qs_init qw(ignore_indices),
    },

    'indices.get_aliases' => {
        doc  => '/api/admin-indices-aliases/',
        path => '{indices}/_aliases/{aliases}',
        qs   => qs_init qw(timeout),
    },

    'indices.get_mapping' => {
        doc  => '/api/admin-indices-get-mapping/',
        path => '{indices|all-type}/{types}/_mapping',
    },

    'indices.get_settings' => {
        doc  => '/api/admin-indices-get-settings/',
        path => '{indices}/_settings',
    },

    'indices.get_template' => {
        doc  => '/api/admin-indices-templates/',
        path => '_template/{template}',
    },

    'indices.get_warmer' => {
        doc  => '/api/admin-indices-warmers/',
        path => '{indices|all-warmer}/_warmer/{warmer|blank}',
    },

    'indices.open' => {
        doc    => '/api/admin-indices-open-close/',
        method => 'POST',
        path   => '{index}/_open',
        qs     => qs_init qw(timeout),
    },

    'indices.optimize' => {
        doc    => '/api/admin-indices-optimize/',
        method => 'POST',
        path   => '{indices}/_optimize',
        qs     => qs_init qw(
            flush ignore_indices max_num_segments
            only_expunge_deletes refresh wait_for_merge),
    },

    'indices.put_alias' => {
        body => {
            desc => 'The settings for the alias, '
                . 'such as `routing` or `filter`',
            required => 1
        },
        doc    => '/api/admin-indices-aliases/',
        method => 'PUT',
        path   => '{index}/_alias/{alias}',
        qs     => qs_init qw(timeout),
    },

    'indices.put_mapping' => {
        body => {
            desc     => 'The mapping definition',
            required => 1
        },
        doc    => '/api/admin-indices-put-mapping/',
        method => 'PUT',
        path   => '{indices|all}/{type}/_mapping',
        qs     => qs_init qw(ignore_conflicts timeout),
    },

    'indices.put_settings' => {
        body => {
            desc     => 'The index settings to be updated',
            required => 1
        },
        doc    => '/api/admin-indices-update-settings/',
        method => 'PUT',
        path   => '{indices}/_settings',
    },

    'indices.put_template' => {
        body => {
            desc     => 'The template definition',
            required => 1
        },
        doc    => '/api/admin-indices-templates/',
        method => 'PUT',
        path   => '_template/{template}',
        qs     => qs_init qw(order timeout),
    },

    'indices.put_warmer' => {
        body => {
            desc => 'The search request definition for'
                . ' the warmer (query, filters, facets, sorting, etc)',
            required => 1
        },
        doc    => '/api/admin-indices-warmers/',
        method => 'PUT',
        path   => '_warmer/{warmer}',
    },

    'indices.refresh' => {
        doc    => '/api/admin-indices-refresh/',
        method => 'POST',
        path   => '{indices}/_refresh',
        qs     => qs_init qw(ignore_indices),
    },

    'indices.segments' => {
        doc  => '/api/admin-indices-segments/',
        path => '{indices}/_segments',
        qs   => qs_init qw(ignore_indices ),
    },

    'indices.stats' => {
        doc  => '/api/admin-indices-stats/',
        path => '/{indices}/_stats',
        qs   => qs_init qw(
            all clear docs fielddata fields filter_cache
            flush get groups id_cache ignore_indices
            indexing merge refresh search store warmer),
    },

    'indices.status' => {
        doc  => '/api/admin-indices-status/',
        path => '{indices}/_status',
        qs   => qs_init qw(ignore_indices recovery snapshot),
    },

    'indices.update_aliases' => {
        body => {
            required => 1,
            desc     => 'The definition of `actions` to perform'
        },
        doc    => '/api/admin-indices-aliases/',
        method => 'POST',
        path   => '_aliases',
        qs     => qs_init qw(timeout),
    },

    'indices.validate_query' => {
        body => { desc => 'The query definition' },
        doc  => '/api/validate/',
        path => '{indices|all-type}/{types}/_validate/query',
        qs   => qs_init qw(explain ignore_indices q source),
    },

);

1;
