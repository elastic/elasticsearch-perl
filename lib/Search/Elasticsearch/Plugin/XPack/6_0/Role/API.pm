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
        doc   => "explore",
        method => 'POST',
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_xpack",
                "_graph", "_explore",
            ],
            [ { index => 0 }, "{index}", "_xpack", "_graph", "_explore" ],
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
        doc   => "",
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
        doc    => "security-api-disable-user",
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
        doc    => "security-api-enable-user",
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
        doc    => "appendix-api-ack-watch",
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
        doc    => "",
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
        doc    => "",
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
        doc    => "appendix-api-delete-watch",
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
        doc    => "appendix-api-execute-watch",
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
        doc   => "appendix-api-get-watch",
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
        doc    => "appendix-api-put-watch",
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
        doc    => "appendix-api-service",
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
        doc    => "appendix-api-service",
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
        doc   => "appendix-api-stats",
        parts => { metric => {} },
        paths => [
            [ { metric => 3 }, "_xpack", "watcher", "stats", "{metric}" ],
            [ {}, "_xpack", "watcher", "stats" ],
        ],
        qs => {
            error_trace => "boolean",
            filter_path => "list",
            human       => "boolean"
        },
    },

    'xpack.watcher.stop' => {
        doc    => "appendix-api-service",
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

