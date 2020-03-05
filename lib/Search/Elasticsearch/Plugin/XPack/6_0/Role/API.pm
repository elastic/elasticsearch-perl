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

    'ccr.delete_auto_follow_pattern' => {
        doc    => "ccr-delete-auto-follow-pattern",
        method => "DELETE",
        parts  => { name => { required => 1 } },
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
        parts  => { index => { required => 1 } },
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
        doc    => "",
        method => "POST",
        parts  => { index => { required => 1 } },
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

    'ccr.pause_follow' => {
        doc    => "ccr-post-pause-follow",
        method => "POST",
        parts  => { index => { required => 1 } },
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
        parts  => { name => { required => 1 } },
        paths  => [ [ { name => 2 }, "_ccr", "auto_follow", "{name}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'ccr.resume_follow' => {
        body   => {},
        doc    => "ccr-post-resume-follow",
        method => "POST",
        parts  => { index => { required => 1 } },
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
        doc    => "",
        method => "POST",
        parts  => { index => { required => 1 } },
        paths  => [ [ { index => 0 }, "{index}", "_ccr", "unfollow" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
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
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
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

    'indices.freeze' => {
        doc    => "frozen",
        method => "POST",
        parts  => { index => { required => 1 } },
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

    'indices.unfreeze' => {
        doc    => "frozen",
        method => "POST",
        parts  => { index => { required => 1 } },
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
            realm_name  => "string",
            username    => "string",
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
        doc    => "delete-license",
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
        doc   => "get-license",
        parts => {},
        paths => [ [ {}, "_xpack", "license" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            local       => "boolean",
        },
    },

    'xpack.license.get_basic_status' => {
        doc   => "get-trial-status",
        parts => {},
        paths => [ [ {}, "_xpack", "license", "basic_status" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.license.get_trial_status' => {
        doc   => "get-basic-status",
        parts => {},
        paths => [ [ {}, "_xpack", "license", "trial_status" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.license.post' => {
        body   => {},
        doc    => "update-license",
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

    'xpack.license.post_start_basic' => {
        doc    => "start-basic",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "license", "start_basic" ] ],
        qs     => {
            acknowledge => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
        },
    },

    'xpack.license.post_start_trial' => {
        doc    => "start-trial",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "license", "start_trial" ] ],
        qs     => {
            acknowledge => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            type        => "string",
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
        body   => {},
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
            allow_no_jobs => "boolean",
            error_trace   => "boolean",
            filter_path   => "list",
            force         => "boolean",
            human         => "boolean",
            timeout       => "time",
        },
    },

    'xpack.ml.delete_calendar' => {
        method => "DELETE",
        parts  => { calendar_id => { required => 1 } },
        paths  => [
            [   { calendar_id => 3 }, "_xpack",
                "ml", "calendars",
                "{calendar_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.delete_calendar_event' => {
        method => "DELETE",
        parts  => {
            calendar_id => { required => 1 },
            event_id    => { required => 1 }
        },
        paths => [
            [   { calendar_id => 3, event_id => 5 },
                "_xpack", "ml", "calendars", "{calendar_id}", "events",
                "{event_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.delete_calendar_job' => {
        method => "DELETE",
        parts =>
            { calendar_id => { required => 1 }, job_id => { required => 1 } },
        paths => [
            [   { calendar_id => 3, job_id => 5 },
                "_xpack", "ml", "calendars", "{calendar_id}", "jobs",
                "{job_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
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

    'xpack.ml.delete_expired_data' => {
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_xpack", "ml", "_delete_expired_data" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.delete_filter' => {
        method => "DELETE",
        parts  => { filter_id => { required => 1 } },
        paths  => [
            [ { filter_id => 3 }, "_xpack", "ml", "filters", "{filter_id}" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.delete_forecast' => {
        doc    => "ml-delete-forecast",
        method => "DELETE",
        parts  => { forecast_id => {}, job_id => { required => 1 } },
        paths  => [
            [   { forecast_id => 5, job_id => 3 },
                "_xpack", "ml", "anomaly_detectors", "{job_id}", "_forecast",
                "{forecast_id}",
            ],
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_forecast",
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
            error_trace         => "boolean",
            filter_path         => "list",
            force               => "boolean",
            human               => "boolean",
            wait_for_completion => "boolean",
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

    'xpack.ml.find_file_structure' => {
        body   => { required => 1 },
        doc    => "ml-find-file-structure",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "ml", "find_file_structure" ] ],
        qs     => {
            charset            => "string",
            column_names       => "list",
            delimiter          => "string",
            error_trace        => "boolean",
            explain            => "boolean",
            filter_path        => "list",
            format             => "enum",
            grok_pattern       => "string",
            has_header_row     => "boolean",
            human              => "boolean",
            lines_to_sample    => "int",
            quote              => "string",
            should_trim_fields => "boolean",
            timeout            => "time",
            timestamp_field    => "string",
            timestamp_format   => "string",
        },
        serialize => "bulk",
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

    'xpack.ml.forecast' => {
        method => "POST",
        parts  => { job_id => { required => 1 } },
        paths  => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "_forecast",
            ],
        ],
        qs => {
            duration    => "time",
            error_trace => "boolean",
            expires_in  => "time",
            filter_path => "list",
            human       => "boolean",
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

    'xpack.ml.get_calendar_events' => {
        parts => { calendar_id => { required => 1 } },
        paths => [
            [   { calendar_id => 3 }, "_xpack",
                "ml",            "calendars",
                "{calendar_id}", "events",
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

    'xpack.ml.get_calendars' => {
        parts => { calendar_id => {} },
        paths => [
            [   { calendar_id => 3 }, "_xpack",
                "ml", "calendars",
                "{calendar_id}",
            ],
            [ {}, "_xpack", "ml", "calendars" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            from        => "int",
            human       => "boolean",
            size        => "int",
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
            allow_no_datafeeds => "boolean",
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
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
            allow_no_datafeeds => "boolean",
            error_trace        => "boolean",
            filter_path        => "list",
            human              => "boolean",
        },
    },

    'xpack.ml.get_filters' => {
        parts => { filter_id => {} },
        paths => [
            [ { filter_id => 3 }, "_xpack", "ml", "filters", "{filter_id}" ],
            [ {}, "_xpack", "ml", "filters" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            from        => "int",
            human       => "boolean",
            size        => "int",
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
            allow_no_jobs => "boolean",
            error_trace   => "boolean",
            filter_path   => "list",
            human         => "boolean",
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
            allow_no_jobs => "boolean",
            error_trace   => "boolean",
            filter_path   => "list",
            human         => "boolean",
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

    'xpack.ml.get_overall_buckets' => {
        body  => {},
        doc   => "ml-get-overall-buckets",
        parts => { job_id => { required => 1 } },
        paths => [
            [   { job_id => 3 }, "_xpack",
                "ml",       "anomaly_detectors",
                "{job_id}", "results",
                "overall_buckets",
            ],
        ],
        qs => {
            allow_no_jobs   => "boolean",
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

    'xpack.ml.info' => {
        parts => {},
        paths => [ [ {}, "_xpack", "ml", "info" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
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

    'xpack.ml.post_calendar_events' => {
        body   => { required => 1 },
        method => "POST",
        parts  => { calendar_id => { required => 1 } },
        paths  => [
            [   { calendar_id => 3 }, "_xpack",
                "ml",            "calendars",
                "{calendar_id}", "events",
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
        parts  => { job_id => { required => 1 } },
        paths  => [
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

    'xpack.ml.put_calendar' => {
        body   => {},
        method => "PUT",
        parts  => { calendar_id => { required => 1 } },
        paths  => [
            [   { calendar_id => 3 }, "_xpack",
                "ml", "calendars",
                "{calendar_id}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.put_calendar_job' => {
        method => "PUT",
        parts =>
            { calendar_id => { required => 1 }, job_id => { required => 1 } },
        paths => [
            [   { calendar_id => 3, job_id => 5 },
                "_xpack", "ml", "calendars", "{calendar_id}", "jobs",
                "{job_id}",
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
            human       => "boolean"
        },
    },

    'xpack.ml.put_filter' => {
        body   => { required => 1 },
        method => "PUT",
        parts  => { filter_id => { required => 1 } },
        paths  => [
            [ { filter_id => 3 }, "_xpack", "ml", "filters", "{filter_id}" ],
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

    'xpack.ml.set_upgrade_mode' => {
        doc    => "ml-set-upgrade-mode",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "ml", "set_upgrade_mode" ] ],
        qs     => {
            enabled     => "boolean",
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            timeout     => "time",
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
            allow_no_datafeeds => "boolean",
            error_trace        => "boolean",
            filter_path        => "list",
            force              => "boolean",
            human              => "boolean",
            timeout            => "time",
        },
    },

    'xpack.ml.update_datafeed' => {
        body   => { required => 1 },
        doc    => "ml-update-datafeed",
        method => "POST",
        parts  => { datafeed_id => { required => 1 } },
        paths  => [
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

    'xpack.ml.update_filter' => {
        body   => { required => 1 },
        method => "POST",
        parts  => { filter_id => { required => 1 } },
        paths  => [
            [   { filter_id => 3 }, "_xpack",
                "ml",          "filters",
                "{filter_id}", "_update",
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
        parts  => { job_id => { required => 1 } },
        paths  => [
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

    'xpack.ml.validate' => {
        body   => { required => 1 },
        method => "POST",
        parts  => {},
        paths => [ [ {}, "_xpack", "ml", "anomaly_detectors", "_validate" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ml.validate_detector' => {
        body   => { required => 1 },
        method => "POST",
        parts  => {},
        paths  => [
            [   {},          "_xpack",
                "ml",        "anomaly_detectors",
                "_validate", "detector"
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
        doc    => "es-monitoring",
        method => "POST",
        parts  => { type => {} },
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

    'xpack.rollup.delete_job' => {
        method => "DELETE",
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 3 }, "_xpack", "rollup", "job", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.rollup.get_jobs' => {
        parts => { id => {} },
        paths => [
            [ { id => 3 }, "_xpack", "rollup", "job", "{id}" ],
            [ {}, "_xpack", "rollup", "job" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.rollup.get_rollup_caps' => {
        parts => { id => {} },
        paths => [
            [ { id => 3 }, "_xpack", "rollup", "data", "{id}" ],
            [ {}, "_xpack", "rollup", "data" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.rollup.get_rollup_index_caps' => {
        parts => { index => { required => 1 } },
        paths =>
            [ [ { index => 0 }, "{index}", "_xpack", "rollup", "data" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.rollup.put_job' => {
        body   => { required => 1 },
        method => "PUT",
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 3 }, "_xpack", "rollup", "job", "{id}" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.rollup.rollup_search' => {
        body  => { required => 1 },
        parts => { index    => { required => 1 }, type => {} },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_rollup_search",
            ],
            [ { index => 0 }, "{index}", "_rollup_search" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            typed_keys  => "boolean",
        },
    },

    'xpack.rollup.start_job' => {
        method => "POST",
        parts  => { id => { required => 1 } },
        paths =>
            [ [ { id => 3 }, "_xpack", "rollup", "job", "{id}", "_start" ] ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.rollup.stop_job' => {
        method => "POST",
        parts  => { id => { required => 1 } },
        paths =>
            [ [ { id => 3 }, "_xpack", "rollup", "job", "{id}", "_stop" ] ],
        qs => {
            error_trace         => "boolean",
            filter_path         => "list",
            human               => "boolean",
            timeout             => "time",
            wait_for_completion => "boolean",
        },
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
        doc    => "security-api-clear-role-cache",
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

    'xpack.security.delete_privileges' => {
        doc    => "",
        method => "DELETE",
        parts =>
            { application => { required => 1 }, name => { required => 1 } },
        paths => [
            [   { application => 3, name => 4 }, "_xpack",
                "security",      "privilege",
                "{application}", "{name}",
            ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.delete_role' => {
        doc    => "security-api-delete-role",
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
        doc    => "security-api-delete-role-mapping",
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
        doc    => "security-api-delete-user",
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
        doc    => "security-api-disable-user",
        method => "PUT",
        parts  => { username => { required => 1 } },
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
        doc    => "security-api-enable-user",
        method => "PUT",
        parts  => { username => { required => 1 } },
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

    'xpack.security.get_privileges' => {
        doc   => "",
        parts => { application => {}, name => {} },
        paths => [
            [   { application => 3, name => 4 }, "_xpack",
                "security",      "privilege",
                "{application}", "{name}",
            ],
            [   { application => 3 }, "_xpack",
                "security", "privilege",
                "{application}",
            ],
            [ {}, "_xpack", "security", "privilege" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.get_role' => {
        doc   => "security-api-get-role",
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
        doc   => "security-api-get-role-mapping",
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
        doc    => "security-api-get-token",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "security", "oauth2", "token" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.get_user' => {
        doc   => "security-api-get-user",
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

    'xpack.security.get_user_privileges' => {
        doc   => "security-api-get-privileges",
        parts => {},
        paths => [ [ {}, "_xpack", "security", "user", "_privileges" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.has_privileges' => {
        body  => { required => 1 },
        doc   => "security-api-has-privileges",
        parts => { user => {} },
        paths => [
            [   { user => 3 }, "_xpack",
                "security", "user",
                "{user}",   "_has_privileges",
            ],
            [ {}, "_xpack", "security", "user", "_has_privileges" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.invalidate_token' => {
        body   => { required => 1 },
        doc    => "security-api-invalidate-token",
        method => "DELETE",
        parts  => {},
        paths  => [ [ {}, "_xpack", "security", "oauth2", "token" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.security.put_privileges' => {
        body   => { required => 1 },
        doc    => "",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_xpack", "security", "privilege" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean",
            refresh     => "enum",
        },
    },

    'xpack.security.put_role' => {
        body   => { required => 1 },
        doc    => "security-api-put-role",
        method => "PUT",
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

    'xpack.security.put_role_mapping' => {
        body   => { required => 1 },
        doc    => "security-api-put-role-mapping",
        method => "PUT",
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

    'xpack.security.put_user' => {
        body   => { required => 1 },
        doc    => "security-api-put-user",
        method => "PUT",
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

    'xpack.sql.clear_cursor' => {
        body   => { required => 1 },
        doc    => "",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "sql", "close" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.sql.query' => {
        body   => { required => 1 },
        doc    => "",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "sql" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            format      => "string",
            human       => "boolean",
        },
    },

    'xpack.sql.translate' => {
        body   => { required => 1 },
        doc    => "",
        method => "POST",
        parts  => {},
        paths  => [ [ {}, "_xpack", "sql", "translate" ] ],
        qs     => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.ssl.certificates' => {
        doc   => "security-api-ssl",
        parts => {},
        paths => [ [ {}, "_xpack", "ssl", "certificates" ] ],
        qs    => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
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
        body   => {},
        doc    => "watcher-api-put-watch",
        method => "PUT",
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 3 }, "_xpack", "watcher", "watch", "{id}" ] ],
        qs     => {
            active          => "boolean",
            error_trace     => "boolean",
            filter_path     => "list",
            human           => "boolean",
            if_primary_term => "number",
            if_seq_no       => "number",
            master_timeout  => "time",
            version         => "number",
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
