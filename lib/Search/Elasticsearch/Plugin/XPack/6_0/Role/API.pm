package Search::Elasticsearch::Plugin::XPack::6_0::Role::API;

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

#=== AUTOGEN - START ===

    'xpack.graph.explore' => {
        body  => {},
        doc   => "graph-explore-api",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_xpack",
                "graph",  "_explore",
            ],
            [ { index => 0 }, "{index}", "_xpack", "graph", "_explore" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            routing     => "string",
            timeout     => "time",
        },
    },

    'xpack.info' => {
        doc   => "info-api",
        parts => {},
        paths => [ [ {}, "_xpack" ] ],
        qs    => {
            categories  => "list",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'xpack.license.delete' => {
        doc    => "license-management",
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_xpack", "license" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.license.get' => {
        doc   => "license-management",
        parts => {},
        paths => [ [ {}, "_xpack", "license" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            local       => "boolean",
        },
    },

    'xpack.license.post' => {
        body   => {},
        doc    => "license-management",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_xpack", "license" ] ],
        qs     => {
            acknowledge => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'xpack.migration.deprecations' => {
        doc   => "migration-api-deprecation",
        parts => { index => {} },
        paths => [
            [   { index => 0 }, "{index}", "_xpack", "migration",
                "deprecations"
            ],
            [ {}, "_xpack", "migration", "deprecations" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.migration.get_assistance' => {
        doc   => "migration-api-assistance",
        parts => { index => { multi => 1 } },
        paths => [
            [   { index => 3 }, "_xpack", "migration", "assistance",
                "{index}"
            ],
            [ {}, "_xpack", "migration", "assistance" ],
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

    'xpack.migration.upgrade' => {
        doc    => "migration-api-upgrade",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [
            [ { index => 3 }, "_xpack", "migration", "upgrade", "{index}" ],
        ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            wait_for_completion => "boolean",
        },
    },

    'xpack.ml.close_job' => {
        doc    => "ml-close-job",
        method => "POST",
        parts  => { job_id => { required => 1 } },
        paths  => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_close",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'xpack.ml.delete_datafeed' => {
        doc    => "ml-delete-datafeed",
        method => "DELETE",
        parts  => { datafeed_id => { required => 1 } },
        paths  => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml", "datafeeds",
                "{datafeed_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
        },
    },
    'xpack.ml.delete_job' => {
        doc    => "ml-delete-job",
        method => "DELETE",
        parts  => { job_id => { required => 1 } },
        paths  => [
            [   { job_id => 3 }, "_xpack",
                "ml", "anomaly_detectors",
                "{job_id}"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
        },
    },

    'xpack.ml.delete_model_snapshot' => {
        doc    => "ml-delete-snapshot",
        method => "DELETE",
        parts =>
            { job_id => { required => 1 }, snapshot_id => { required => 1 } },
        paths => [
            [   { job_id => 3, snapshot_id => 5 },
                "_xpack", "ml", "anomaly_detectors", "{job_id}",
                "model_snapshots", "{snapshot_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.flush_job' => {
        body   => {},
        doc    => "ml-flush-job",
        method => "POST",
        parts  => { job_id => { required => 1 } },
        paths  => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_flush",
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

    'xpack.ml.get_buckets' => {
        body  => {},
        doc   => "ml-get-bucket",
        parts => { job_id => { required => 1 }, timestamp => {} },
        paths => [
            [   { job_id => 3, timestamp => 6 },
                "_xpack", "ml", "anomaly_detectors", "{job_id}", "results",
                "buckets", "{timestamp}",
            ],
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "results",
                "buckets",
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

    'xpack.ml.get_categories' => {
        body  => {},
        doc   => "ml-get-category",
        parts => { category_id => {}, job_id => { required => 1 } },
        paths => [
            [   { category_id => 6, job_id => 3 }, "_xpack",
                "ml",         "anomaly_detectors",
                "{job_id}",   "results",
                "categories", "{category_id}",
            ],
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "results",
                "categories",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            from        => "int",
            human       => "boolean",
            size        => "int",
        },
    },

    'xpack.ml.get_datafeed_stats' => {
        doc   => "ml-get-datafeed-stats",
        parts => { datafeed_id => {} },
        paths => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml",            "datafeeds",
                "{datafeed_id}", "_stats",
            ],
            [ {}, "_xpack", "ml", "datafeeds", "_stats" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.get_datafeeds' => {
        doc   => "ml-get-datafeed",
        parts => { datafeed_id => {} },
        paths => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml", "datafeeds",
                "{datafeed_id}",
            ],
            [ {}, "_xpack", "ml", "datafeeds" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },
    'xpack.ml.get_influencers' => {
        body  => {},
        doc   => "ml-get-influencer",
        parts => { job_id => { required => 1 } },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "results",
                "influencers",
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

    'xpack.ml.get_job_stats' => {
        doc   => "ml-get-job-stats",
        parts => { job_id => {} },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_stats",
            ],
            [ {}, "_xpack", "ml", "anomaly_detectors", "_stats" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.get_jobs' => {
        doc   => "ml-get-job",
        parts => { job_id => {} },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml", "anomaly_detectors",
                "{job_id}"
            ],
            [ {}, "_xpack", "ml", "anomaly_detectors" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.get_model_snapshots' => {
        body  => {},
        doc   => "ml-get-snapshot",
        parts => { job_id => { required => 1 }, snapshot_id => {} },
        paths => [
            [   { job_id => 3, snapshot_id => 5 },
                "_xpack", "ml", "anomaly_detectors", "{job_id}",
                "model_snapshots", "{snapshot_id}",
            ],
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "model_snapshots",
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

    'xpack.ml.get_records' => {
        body  => {},
        doc   => "ml-get-record",
        parts => { job_id => { required => 1 } },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "results",
                "records",
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

    'xpack.ml.open_job' => {
        doc    => "ml-open-job",
        method => "POST",
        parts  => {
            ignore_downtime => {},
            job_id          => { required => 1 },
            timeout         => {}
        },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_open",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.post_data' => {
        body   => { required => 1 },
        doc    => "ml-post-data",
        method => "POST",
        parts => { job_id => { required => 1 } },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_data",
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

    'xpack.ml.preview_datafeed' => {
        doc   => "ml-preview-datafeed",
        parts => { datafeed_id => { required => 1 } },
        paths => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml",            "datafeeds",
                "{datafeed_id}", "_preview",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.put_datafeed' => {
        body   => { required => 1 },
        doc    => "ml-put-datafeed",
        method => "PUT",
        parts => { datafeed_id => { required => 1 } },
        paths => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml", "datafeeds",
                "{datafeed_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.put_job' => {
        body   => { required => 1 },
        doc    => "ml-put-job",
        method => "PUT",
        parts => { job_id => { required => 1 } },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml", "anomaly_detectors",
                "{job_id}"
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.revert_model_snapshot' => {
        body   => {},
        doc    => "ml-revert-snapshot",
        method => "POST",
        parts =>
            { job_id => { required => 1 }, snapshot_id => { required => 1 } },
        paths => [
            [   { job_id => 3, snapshot_id => 5 }, "_xpack",
                "ml",            "anomaly_detectors",
                "{job_id}",      "model_snapshots",
                "{snapshot_id}", "_revert",
            ],
        ],
        qs => {
            delete_intervening_results => "boolean",
            error_trace                => "boolean",
            filter_path                => "list",
            human                      => "boolean",
        },
    },

    'xpack.ml.start_datafeed' => {
        body   => {},
        doc    => "ml-start-datafeed",
        method => "POST",
        parts  => { datafeed_id => { required => 1 } },
        paths  => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml",            "datafeeds",
                "{datafeed_id}", "_start",
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

    'xpack.ml.stop_datafeed' => {
        doc    => "ml-stop-datafeed",
        method => "POST",
        parts  => { datafeed_id => { required => 1 } },
        paths  => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml",            "datafeeds",
                "{datafeed_id}", "_stop",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            force       => "boolean",
            human       => "boolean",
            timeout     => "time",
        },
    },

    'xpack.ml.update_datafeed' => {
        body   => { required => 1 },
        doc    => "ml-update-datafeed",
        method => "POST",
        parts => { datafeed_id => { required => 1 } },
        paths => [
            [   { datafeed_id => 3 }, "_xpack",
                "ml",            "datafeeds",
                "{datafeed_id}", "_update",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.update_job' => {
        body   => { required => 1 },
        doc    => "ml-update-job",
        method => "POST",
        parts => { job_id => { required => 1 } },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_update",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.update_model_snapshot' => {
        body   => { required => 1 },
        doc    => "ml-update-snapshot",
        method => "POST",
        parts =>
            { job_id => { required => 1 }, snapshot_id => { required => 1 } },
        paths => [
            [   { job_id => 3, snapshot_id => 5 }, "_xpack",
                "ml",            "anomaly_detectors",
                "{job_id}",      "model_snapshots",
                "{snapshot_id}", "_update",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },



    'xpack.monitoring.bulk' => {
        body   => { required => 1 },
        doc    => "appendix-api-bulk",
        method => "POST",
        parts  => { type     => {} },
        paths  => [
            [ { type => 2 }, "_xpack", "monitoring", "{type}", "_bulk" ],
            [ {}, "_xpack", "monitoring", "_bulk" ],
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

    'xpack.security.authenticate' => {
        doc   => "security-api-authenticate",
        parts => {},
        paths => [ [ {}, "_xpack", "security", "_authenticate" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.change_password' => {
        body   => { required => 1 },
        doc    => "security-api-change-password",
        method => "PUT",
        parts  => { username => {} },
        paths  => [
            [   { username => 3 }, "_xpack",
                "security",   "user",
                "{username}", "_password",
            ],
            [ {}, "_xpack", "security", "user", "_password" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.clear_cached_realms' => {
        doc    => "security-api-clear-cache",
        method => "POST",
        parts  => { realms => { multi => 1, required => 1 } },
        paths  => [
            [   { realms => 3 }, "_xpack",
                "security", "realm",
                "{realms}", "_clear_cache",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            usernames   => "list",
        },
    },

    'xpack.security.clear_cached_roles' => {
        doc    => "",
        method => "POST",
        parts  => { name => { multi => 1, required => 1 } },
        paths  => [
            [   { name => 3 }, "_xpack",
                "security", "role",
                "{name}",   "_clear_cache",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.delete_role' => {
        doc    => "",
        method => "DELETE",
        parts  => { name => { required => 1 } },
        paths =>
            [ [ { name => 3 }, "_xpack", "security", "role", "{name}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.delete_role_mapping' => {
        doc    => "",
        method => "DELETE",
        parts  => { name => { required => 1 } },
        paths  => [
            [ { name => 3 }, "_xpack", "security", "role_mapping", "{name}" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.delete_user' => {
        doc    => "",
        method => "DELETE",
        parts  => { username => { required => 1 } },
        paths  => [
            [ { username => 3 }, "_xpack", "security", "user", "{username}" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.disable_user' => {
        doc    => "",
        method => "PUT",
        parts  => { username => {} },
        paths  => [
            [   { username => 3 }, "_xpack",
                "security",   "user",
                "{username}", "_disable",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.enable_user' => {
        doc    => "",
        method => "PUT",
        parts  => { username => {} },
        paths  => [
            [   { username => 3 }, "_xpack", "security", "user",
                "{username}", "_enable",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.get_role' => {
        doc   => "",
        parts => { name => {} },
        paths => [
            [ { name => 3 }, "_xpack", "security", "role", "{name}" ],
            [ {}, "_xpack", "security", "role" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.get_role_mapping' => {
        doc   => "",
        parts => { name => {} },
        paths => [
            [ { name => 3 }, "_xpack", "security", "role_mapping", "{name}" ],
            [ {}, "_xpack", "security", "role_mapping" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.get_token' => {
        body   => { required => 1 },
        doc    => "",
        method => "POST",
        parts  => {},
        paths => [ [ {}, "_xpack", "security", "oauth2", "token" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.get_user' => {
        doc   => "",
        parts => { username => { multi => 1 } },
        paths => [
            [ { username => 3 }, "_xpack", "security", "user", "{username}" ],
            [ {}, "_xpack", "security", "user" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.invalidate_token' => {
        body   => { required => 1 },
        doc    => "",
        method => "DELETE",
        parts  => {},
        paths => [ [ {}, "_xpack", "security", "oauth2", "token" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.put_role' => {
        body   => { required => 1 },
        doc    => "",
        method => "PUT",
        parts => { name => { required => 1 } },
        paths =>
            [ [ { name => 3 }, "_xpack", "security", "role", "{name}" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.put_role_mapping' => {
        body   => { required => 1 },
        doc    => "",
        method => "PUT",
        parts => { name => { required => 1 } },
        paths => [
            [ { name => 3 }, "_xpack", "security", "role_mapping", "{name}" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.put_user' => {
        body   => { required => 1 },
        doc    => "",
        method => "PUT",
        parts => { username => { required => 1 } },
        paths => [
            [ { username => 3 }, "_xpack", "security", "user", "{username}" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.usage' => {
        doc   => "",
        parts => {},
        paths => [ [ {}, "_xpack", "usage" ] ],
        qs    => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'xpack.watcher.ack_watch' => {
        doc    => "watcher-api-ack-watch",
        method => "PUT",
        parts =>
            { action_id => { multi => 1 }, watch_id => { required => 1 } },
        paths => [
            [   { action_id => 5, watch_id => 3 }, "_xpack",
                "watcher",    "watch",
                "{watch_id}", "_ack",
                "{action_id}",
            ],
            [   { watch_id => 3 }, "_xpack", "watcher", "watch",
                "{watch_id}", "_ack",
            ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'xpack.watcher.activate_watch' => {
        doc    => "watcher-api-activate-watch",
        method => "PUT",
        parts  => { watch_id => { required => 1 } },
        paths  => [
            [   { watch_id => 3 }, "_xpack",
                "watcher",    "watch",
                "{watch_id}", "_activate",
            ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'xpack.watcher.deactivate_watch' => {
        doc    => "watcher-api-deactivate-watch",
        method => "PUT",
        parts  => { watch_id => { required => 1 } },
        paths  => [
            [   { watch_id => 3 }, "_xpack",
                "watcher",    "watch",
                "{watch_id}", "_deactivate",
            ],
        ],
        qs => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'xpack.watcher.delete_watch' => {
        doc    => "watcher-api-delete-watch",
        method => "DELETE",
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 3 }, "_xpack", "watcher", "watch", "{id}" ] ],
        qs     => {
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'xpack.watcher.execute_watch' => {
        body   => {},
        doc    => "watcher-api-execute-watch",
        method => "PUT",
        parts  => { id => {} },
        paths  => [
            [ { id => 3 }, "_xpack", "watcher", "watch", "{id}", "_execute" ],
            [ {}, "_xpack", "watcher", "watch", "_execute" ],
        ],
        qs => {
            debug       => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'xpack.watcher.get_watch' => {
        doc   => "watcher-api-get-watch",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 3 }, "_xpack", "watcher", "watch", "{id}" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.watcher.put_watch' => {
        body   => { required => 1 },
        doc    => "watcher-api-put-watch",
        method => "PUT",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 3 }, "_xpack", "watcher", "watch", "{id}" ] ],
        qs => {
            active         => "boolean",
            error_trace    => "boolean",
            filter_path    => "list",
            human          => "boolean",
            master_timeout => "time",
        },
    },

    'xpack.watcher.restart' => {
        doc    => "watcher-api-restart",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "watcher", "_restart" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.watcher.start' => {
        doc    => "watcher-api-start",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "watcher", "_start" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.watcher.stats' => {
        doc   => "watcher-api-stats",
        parts => { metric => {} },
        paths => [
            [ { metric => 3 }, "_xpack", "watcher", "stats", "{metric}" ],
            [ {}, "_xpack", "watcher", "stats" ],
        ],
        qs => {
            emit_stacktraces => "boolean",
            error_trace      => "boolean",
            filter_path      => "list",
            human            => "boolean",
        },
    },

    'xpack.watcher.stop' => {
        doc    => "watcher-api-stop",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "watcher", "_stop" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

#=== AUTOGEN - END ===
);
__PACKAGE__->_qs_init( \%API );
1;

__END__

# ABSTRACT: This class contains the spec for the Elasticsearch XPack APIs for 6.x
