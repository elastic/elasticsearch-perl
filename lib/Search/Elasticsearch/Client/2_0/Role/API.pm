# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Client::2_0::Role::API;

use Moo::Role;
with 'Search::Elasticsearch::Role::API';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

has 'api_version' => ( is => 'ro', default => '2_0' );

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
            'detect_noop',     '_retry_on_conflict',
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
            fields      => "list",
            filter_path => "list",
            refresh     => "boolean",
            routing     => "string",
            timeout     => "time",
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
            allow_no_indices         => "boolean",
            analyze_wildcard         => "boolean",
            analyzer                 => "string",
            default_operator         => "enum",
            df                       => "string",
            expand_wildcards         => "enum",
            filter_path              => "list",
            ignore_unavailable       => "boolean",
            lenient                  => "boolean",
            lowercase_expanded_terms => "boolean",
            min_score                => "number",
            preference               => "string",
            q                        => "string",
            routing                  => "string",
        },
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
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            percolate_index    => "string",
            percolate_type     => "string",
            preference         => "string",
            routing            => "list",
            version            => "number",
            version_type       => "enum",
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
            routing      => "string",
            timeout      => "time",
            version      => "number",
            version_type => "enum",
        },
    },

    'delete_by_query' => {
        body   => {},
        doc    => "plugins-delete-by-query",
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
            allow_no_indices   => "boolean",
            analyzer           => "string",
            default_operator   => "enum",
            df                 => "string",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            q                  => "string",
            routing            => "string",
            timeout            => "time",
        },
    },

    'delete_script' => {
        doc    => "modules-scripting",
        method => "DELETE",
        parts  => { id => { required => 1 }, lang => { required => 1 } },
        paths => [ [ { id => 2, lang => 1 }, "_scripts", "{lang}", "{id}" ] ],
        qs    => {
            filter_path  => "list",
            version      => "number",
            version_type => "enum"
        },
    },

    'delete_template' => {
        doc    => "search-template",
        method => "DELETE",
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 2 }, "_search", "template", "{id}" ] ],
        qs     => {
            filter_path  => "list",
            version      => "number",
            version_type => "enum"
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
        },
    },

    'field_stats' => {
        body  => {},
        doc   => "search-field-stats",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 0 }, "{index}", "_field_stats" ],
            [ {}, "_field_stats" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            fields             => "list",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            level              => "enum",
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
            version         => "number",
            version_type    => "enum",
        },
    },

    'get_script' => {
        doc   => "modules-scripting",
        parts => { id => { required => 1 }, lang => { required => 1 } },
        paths => [ [ { id => 2, lang => 1 }, "_scripts", "{lang}", "{id}" ] ],
        qs    => {
            filter_path  => "list",
            version      => "number",
            version_type => "enum"
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

    'get_template' => {
        doc   => "search-template",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_search", "template", "{id}" ] ],
        qs    => {
            filter_path  => "list",
            version      => "number",
            version_type => "enum"
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
            refresh      => "boolean",
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

    'mpercolate' => {
        body => { required => 1 },
        doc  => "search-percolate",
        parts => { index => {}, type => {} },
        paths => [
            [ { index => 0, type => 1 }, "{index}", "{type}", "_mpercolate" ],
            [ { index => 0 }, "{index}", "_mpercolate" ],
            [ {}, "_mpercolate" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
        },
        serialize => "bulk",
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
            field_statistics => "boolean",
            fields           => "list",
            filter_path      => "list",
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
        qs => {
            allow_no_indices     => "boolean",
            expand_wildcards     => "enum",
            filter_path          => "list",
            ignore_unavailable   => "boolean",
            percolate_format     => "enum",
            percolate_index      => "string",
            percolate_preference => "string",
            percolate_routing    => "string",
            percolate_type       => "string",
            preference           => "string",
            routing              => "list",
            version              => "number",
            version_type         => "enum",
        },
    },

    'ping' => {
        doc    => "",
        method => "HEAD",
        parts  => {},
        paths  => [ [ {} ] ],
        qs     => {}
    },

    'put_script' => {
        body   => { required => 1 },
        doc    => "modules-scripting",
        method => "PUT",
        parts => { id => { required => 1 }, lang => { required => 1 } },
        paths => [ [ { id => 2, lang => 1 }, "_scripts", "{lang}", "{id}" ] ],
        qs => {
            filter_path  => "list",
            op_type      => "enum",
            version      => "number",
            version_type => "enum",
        },
    },

    'put_template' => {
        body   => { required => 1 },
        doc    => "search-template",
        method => "PUT",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_search", "template", "{id}" ] ],
        qs => {
            filter_path  => "list",
            op_type      => "enum",
            version      => "number",
            version_type => "enum",
        },
    },

    'reindex' => {
        body   => { required => 1 },
        doc    => "plugins-reindex",
        method => "POST",
        parts  => {},
        paths => [ [ {}, "_reindex" ] ],
        qs => {
            consistency         => "enum",
            filter_path         => "list",
            refresh             => "boolean",
            requests_per_second => "number",
            timeout             => "time",
            wait_for_completion => "boolean",
        },
    },

    'reindex_rethrottle' => {
        doc    => "docs-reindex",
        method => "POST",
        parts  => { task_id => {} },
        paths =>
            [ [ { task_id => 1 }, "_reindex", "{task_id}", "_rethrottle" ] ],
        qs => { filter_path => "list", requests_per_second => "number" },
    },

    'render_search_template' => {
        body  => {},
        doc   => "search-template",
        parts => { id => {} },
        paths => [
            [ { id => 2 }, "_render", "template", "{id}" ],
            [ {}, "_render", "template" ],
        ],
        qs => { filter_path => "list" },
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
            allow_no_indices         => "boolean",
            analyze_wildcard         => "boolean",
            analyzer                 => "string",
            default_operator         => "enum",
            df                       => "string",
            expand_wildcards         => "enum",
            explain                  => "boolean",
            fielddata_fields         => "list",
            fields                   => "list",
            filter_path              => "list",
            from                     => "number",
            ignore_unavailable       => "boolean",
            lenient                  => "boolean",
            lowercase_expanded_terms => "boolean",
            preference               => "string",
            q                        => "string",
            request_cache            => "boolean",
            routing                  => "list",
            scroll                   => "time",
            search_type              => "enum",
            size                     => "number",
            sort                     => "list",
            stats                    => "list",
            suggest_field            => "string",
            suggest_mode             => "enum",
            suggest_size             => "number",
            suggest_text             => "string",
            terminate_after          => "number",
            timeout                  => "time",
            track_scores             => "boolean",
            version                  => "boolean",
        },
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
            [ { index => 0 }, "{index}", "_search", "exists" ],
            [ {}, "_search", "exists" ],
        ],
        qs => {
            allow_no_indices         => "boolean",
            analyze_wildcard         => "boolean",
            analyzer                 => "string",
            default_operator         => "enum",
            df                       => "string",
            expand_wildcards         => "enum",
            filter_path              => "list",
            ignore_unavailable       => "boolean",
            lenient                  => "boolean",
            lowercase_expanded_terms => "boolean",
            min_score                => "number",
            preference               => "string",
            q                        => "string",
            routing                  => "string",
        },
    },

    'search_shards' => {
        doc   => "search-shards",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_search_shards",
            ],
            [ { index => 0 }, "{index}", "_search_shards" ],
            [ {}, "_search_shards" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            local              => "boolean",
            preference         => "string",
            routing            => "string",
        },
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
            [ { index => 0 }, "{index}", "_search", "template" ],
            [ {}, "_search", "template" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            preference         => "string",
            routing            => "list",
            scroll             => "time",
            search_type        => "enum",
        },
    },

    'suggest' => {
        body   => { required => 1 },
        doc    => "search-suggesters",
        method => "POST",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_suggest" ], [ {}, "_suggest" ] ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            preference         => "string",
            routing            => "string",
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
            dfs              => "boolean",
            field_statistics => "boolean",
            fields           => "list",
            filter_path      => "list",
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
            refresh           => "boolean",
            retry_on_conflict => "number",
            routing           => "string",
            script            => "string",
            script_id         => "string",
            scripted_upsert   => "boolean",
            timeout           => "time",
            timestamp         => "time",
            ttl               => "time",
            version           => "number",
            version_type      => "enum",
        },
    },

    'update_by_query' => {
        body   => {},
        doc    => "plugins-reindex",
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
            _source                  => "list",
            _source_exclude          => "list",
            _source_include          => "list",
            allow_no_indices         => "boolean",
            analyze_wildcard         => "boolean",
            analyzer                 => "string",
            conflicts                => "enum",
            consistency              => "enum",
            default_operator         => "enum",
            df                       => "string",
            expand_wildcards         => "enum",
            explain                  => "boolean",
            fielddata_fields         => "list",
            fields                   => "list",
            filter_path              => "list",
            from                     => "number",
            ignore_unavailable       => "boolean",
            lenient                  => "boolean",
            lowercase_expanded_terms => "boolean",
            preference               => "string",
            q                        => "string",
            refresh                  => "boolean",
            request_cache            => "boolean",
            requests_per_second      => "number",
            routing                  => "list",
            scroll                   => "time",
            scroll_size              => "number",
            search_timeout           => "time",
            search_type              => "enum",
            size                     => "number",
            sort                     => "list",
            stats                    => "list",
            suggest_field            => "string",
            suggest_mode             => "enum",
            suggest_size             => "number",
            suggest_text             => "string",
            terminate_after          => "number",
            timeout                  => "time",
            track_scores             => "boolean",
            version                  => "boolean",
            version_type             => "boolean",
            wait_for_completion      => "boolean",
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
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
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
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
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
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
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
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cat.health' => {
        doc   => "cat-health",
        parts => {},
        paths => [ [ {}, "_cat", "health" ] ],
        qs    => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            ts             => "boolean",
            v              => "boolean",
        },
    },

    'cat.help' => {
        doc   => "cat",
        parts => {},
        paths => [ [ {}, "_cat" ] ],
        qs => { help => "boolean" },
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
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            pri            => "boolean",
            v              => "boolean",
        },
    },

    'cat.master' => {
        doc   => "cat-master",
        parts => {},
        paths => [ [ {}, "_cat", "master" ] ],
        qs    => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cat.nodeattrs' => {
        doc   => "cat-nodeattrs",
        parts => {},
        paths => [ [ {}, "_cat", "nodeattrs" ] ],
        qs    => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cat.nodes' => {
        doc   => "cat-nodes",
        parts => {},
        paths => [ [ {}, "_cat", "nodes" ] ],
        qs    => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cat.pending_tasks' => {
        doc   => "cat-pending-tasks",
        parts => {},
        paths => [ [ {}, "_cat", "pending_tasks" ] ],
        qs    => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cat.plugins' => {
        doc   => "cat-plugins",
        parts => {},
        paths => [ [ {}, "_cat", "plugins" ] ],
        qs    => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
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
            h              => "list",
            help           => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cat.repositories' => {
        doc   => "cat-repositories",
        parts => {},
        paths => [ [ {}, "_cat", "repositories" ] ],
        qs    => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
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
        qs => { h => "list", help => "boolean", v => "boolean" },
    },

    'cat.shards' => {
        doc   => "cat-shards",
        parts => { index => { multi => 1 } },
        paths => [
            [ { index => 2 }, "_cat", "shards", "{index}" ],
            [ {}, "_cat", "shards" ],
        ],
        qs => {
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cat.snapshots' => {
        doc   => "cat-snapshots",
        parts => { repository => { multi => 1, required => 1 } },
        paths =>
            [ [ { repository => 2 }, "_cat", "snapshots", "{repository}" ] ],
        qs => {
            h                  => "list",
            help               => "boolean",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            v                  => "boolean",
        },
    },

    'cat.thread_pool' => {
        doc   => "cat-thread-pool",
        parts => {},
        paths => [ [ {}, "_cat", "thread_pool" ] ],
        qs    => {
            full_id        => "boolean",
            h              => "list",
            help           => "boolean",
            local          => "boolean",
            master_timeout => "time",
            v              => "boolean",
        },
    },

    'cluster.get_settings' => {
        doc   => "cluster-update-settings",
        parts => {},
        paths => [ [ {}, "_cluster", "settings" ] ],
        qs    => {
            filter_path    => "list",
            flat_settings  => "boolean",
            master_timeout => "time",
            timeout        => "time",
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
        qs     => {
            filter_path    => "list",
            flat_settings  => "boolean",
            master_timeout => "time",
            timeout        => "time",
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
            explain        => "boolean",
            filter_path    => "list",
            master_timeout => "time",
            metric         => "list",
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
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            ignore_unavailable => "boolean",
            local              => "boolean",
            master_timeout     => "time",
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
            analyzer     => "string",
            attributes   => "list",
            char_filter  => "list",
            char_filters => "list",
            explain      => "boolean",
            field        => "string",
            filter       => "list",
            filter_path  => "list",
            filters      => "list",
            format       => "enum",
            prefer_local => "boolean",
            text         => "list",
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
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            fielddata          => "boolean",
            fields             => "list",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            query              => "boolean",
            recycler           => "boolean",
            request            => "boolean",
        },
    },

    'indices.close' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { multi => 1, required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_close" ] ],
        qs     => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
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
            filter_path      => "list",
            master_timeout   => "time",
            timeout          => "time",
            update_all_types => "boolean",
        },
    },

    'indices.delete' => {
        doc    => "indices-delete-index",
        method => "DELETE",
        parts  => { index => { multi => 1, required => 1 } },
        paths => [ [ { index => 0 }, "{index}" ] ],
        qs => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
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
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
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
            name  => { multi => 1, required => 1 },
        },
        paths =>
            [ [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ] ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'indices.exists' => {
        doc    => "indices-exists",
        method => "HEAD",
        parts  => { index => { multi => 1, required => 1 } },
        paths => [ [ { index => 0 }, "{index}" ] ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
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
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
    },

    'indices.exists_template' => {
        doc    => "indices-templates",
        method => "HEAD",
        parts  => { name => { required => 1 } },
        paths  => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs => { local => "boolean", master_timeout => "time" },
    },

    'indices.exists_type' => {
        doc    => "indices-types-exists",
        method => "HEAD",
        parts  => {
            index => { multi => 1, required => 1 },
            type  => { multi => 1, required => 1 },
        },
        paths => [ [ { index => 0, type => 1 }, "{index}", "{type}" ] ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
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
            expand_wildcards   => "enum",
            filter_path        => "list",
            force              => "boolean",
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
            expand_wildcards   => "enum",
            filter_path        => "list",
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
            expand_wildcards     => "enum",
            filter_path          => "list",
            flush                => "boolean",
            ignore_unavailable   => "boolean",
            max_num_segments     => "number",
            only_expunge_deletes => "boolean",
            wait_for_merge       => "boolean",
        },
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
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            local              => "boolean",
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
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
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
        qs =>
            { filter_path => "list", local => "boolean", timeout => "time" },
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
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            include_defaults   => "boolean",
            local              => "boolean",
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
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            local              => "boolean",
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
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            human              => "boolean",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
    },

    'indices.get_template' => {
        doc   => "indices-templates",
        parts => { name => { multi => 1 } },
        paths =>
            [ [ { name => 1 }, "_template", "{name}" ], [ {}, "_template" ] ],
        qs => {
            filter_path    => "list",
            flat_settings  => "boolean",
            local          => "boolean",
            master_timeout => "time",
        },
    },

    'indices.get_upgrade' => {
        doc   => "indices-upgrade",
        parts => { index => { multi => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_upgrade" ], [ {}, "_upgrade" ] ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            human              => "boolean",
            ignore_unavailable => "boolean",
        },
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
            [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ],
            [ { index => 0 }, "{index}", "_warmer" ],
            [ { name  => 1 }, "_warmer", "{name}" ],
            [ {}, "_warmer" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            local              => "boolean",
        },
    },

    'indices.open' => {
        doc    => "indices-open-close",
        method => "POST",
        parts  => { index => { multi => 1, required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_open" ] ],
        qs     => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            timeout            => "time",
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
            allow_no_indices     => "boolean",
            expand_wildcards     => "enum",
            filter_path          => "list",
            flush                => "boolean",
            ignore_unavailable   => "boolean",
            max_num_segments     => "number",
            only_expunge_deletes => "boolean",
            wait_for_merge       => "boolean",
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
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
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
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            timeout            => "time",
            update_all_types   => "boolean",
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
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            flat_settings      => "boolean",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
        },
    },

    'indices.put_template' => {
        body   => { required => 1 },
        doc    => "indices-templates",
        method => "PUT",
        parts => { name => { required => 1 } },
        paths => [ [ { name => 1 }, "_template", "{name}" ] ],
        qs => {
            create         => "boolean",
            filter_path    => "list",
            flat_settings  => "boolean",
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
            index => { multi    => 1 },
            name  => { required => 1 },
            type  => { multi    => 1 },
        },
        paths => [
            [   { index => 0, name => 3, type => 1 },
                "{index}", "{type}", "_warmer", "{name}",
            ],
            [ { index => 0, name => 2 }, "{index}", "_warmer", "{name}" ],
            [ { name => 1 }, "_warmer", "{name}" ],
        ],
        qs => {
            allow_no_indices   => "boolean",
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            master_timeout     => "time",
            request_cache      => "boolean",
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
            expand_wildcards   => "enum",
            filter_path        => "list",
            force              => "boolean",
            ignore_unavailable => "boolean",
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
            expand_wildcards   => "enum",
            filter_path        => "list",
            ignore_unavailable => "boolean",
            status             => "list",
        },
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
        qs => {
            completion_fields => "list",
            fielddata_fields  => "list",
            fields            => "list",
            filter_path       => "list",
            groups            => "list",
            human             => "boolean",
            level             => "enum",
            types             => "list",
        },
    },

    'indices.update_aliases' => {
        body   => { required => 1 },
        doc    => "indices-aliases",
        method => "POST",
        parts  => {},
        paths => [ [ {}, "_aliases" ] ],
        qs => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
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
            expand_wildcards      => "enum",
            filter_path           => "list",
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
            allow_no_indices         => "boolean",
            analyze_wildcard         => "boolean",
            analyzer                 => "string",
            default_operator         => "enum",
            df                       => "string",
            expand_wildcards         => "enum",
            explain                  => "boolean",
            filter_path              => "list",
            ignore_unavailable       => "boolean",
            lenient                  => "boolean",
            lowercase_expanded_terms => "boolean",
            q                        => "string",
            rewrite                  => "boolean",
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
            filter_path         => "list",
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
            filter_path   => "list",
            flat_settings => "boolean",
            human         => "boolean",
            timeout       => "time",
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
            completion_fields => "list",
            fielddata_fields  => "list",
            fields            => "list",
            filter_path       => "list",
            groups            => "boolean",
            human             => "boolean",
            level             => "enum",
            timeout           => "time",
            types             => "list",
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
            filter_path         => "list",
            master_timeout      => "time",
            wait_for_completion => "boolean",
        },
    },

    'snapshot.create_repository' => {
        body   => { required => 1 },
        doc    => "modules-snapshots",
        method => "PUT",
        parts => { repository => { required => 1 } },
        paths => [ [ { repository => 1 }, "_snapshot", "{repository}" ] ],
        qs => {
            filter_path    => "list",
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
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'snapshot.delete_repository' => {
        doc    => "modules-snapshots",
        method => "DELETE",
        parts  => { repository => { multi => 1, required => 1 } },
        paths  => [ [ { repository => 1 }, "_snapshot", "{repository}" ] ],
        qs     => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
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
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'snapshot.get_repository' => {
        doc   => "modules-snapshots",
        parts => { repository => { multi => 1 } },
        paths => [
            [ { repository => 1 }, "_snapshot", "{repository}" ],
            [ {}, "_snapshot" ],
        ],
        qs => {
            filter_path    => "list",
            local          => "boolean",
            master_timeout => "time"
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
            filter_path         => "list",
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
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'snapshot.verify_repository' => {
        doc    => "modules-snapshots",
        method => "POST",
        parts  => { repository => { required => 1 } },
        paths  => [
            [ { repository => 1 }, "_snapshot", "{repository}", "_verify" ],
        ],
        qs => {
            filter_path    => "list",
            master_timeout => "time",
            timeout        => "time"
        },
    },

    'tasks.cancel' => {
        doc    => "tasks-cancel",
        method => "POST",
        parts  => { task_id => {} },
        paths  => [
            [ { task_id => 1 }, "_tasks", "{task_id}", "_cancel" ],
            [ {}, "_tasks", "_cancel" ],
        ],
        qs => {
            actions     => "list",
            filter_path => "list",
            node_id     => "list",
            parent_node => "string",
            parent_task => "string",
        },
    },

    'tasks.list' => {
        doc   => "tasks-list",
        parts => { task_id => {} },
        paths =>
            [ [ { task_id => 1 }, "_tasks", "{task_id}" ], [ {}, "_tasks" ] ],
        qs => {
            actions             => "list",
            detailed            => "boolean",
            filter_path         => "list",
            node_id             => "list",
            parent_node         => "string",
            parent_task         => "string",
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
is the definition for the L<Search::Elasticsearch::Client::2_0::Direct/index()> method:

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
            refresh      => "boolean",
            routing      => "string",
            timeout      => "time",
            timestamp    => "time",
            ttl          => "time",
            version      => "number",
            version_type => "enum",
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

L<Search::Elasticsearch::Client::2_0::Direct>

=back
