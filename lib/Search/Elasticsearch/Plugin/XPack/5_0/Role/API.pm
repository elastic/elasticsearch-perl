package Search::Elasticsearch::Plugin::XPack::5_0::Role::API;

use Moo::Role;
with 'Search::Elasticsearch::Role::API';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

has 'api_version' => ( is => 'ro', default => '5_0' );

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

    'graph.explore' => {
        body  => {},
        doc   => "explore",
        parts => { index => { multi => 1 }, type => { multi => 1 } },
        paths => [
            [   { index => 0, type => 1 }, "{index}",
                "{type}", "_graph",
                "explore",
            ],
            [ { index => 0 }, "{index}", "_graph", "explore" ],
        ],
        qs => { filter_path => "list", routing => "string", timeout => "time" },
    },

    'license.get' => {
        doc   => "license-management",
        parts => {},
        paths => [ [ {}, "_license" ] ],
        qs    => { filter_path => "list", local => "boolean" },
    },

    'license.post' => {
        body   => {},
        doc    => "license-management",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_license" ] ],
        qs     => { acknowledge => "boolean", filter_path => "list" },
    },

    'shield.authenticate' => {
        doc   => "",
        parts => {},
        paths => [ [ {}, "_shield", "authenticate" ] ],
        qs => { filter_path => "list" },
    },

    'shield.clear_cached_realms' => {
        doc    => "",
        method => "POST",
        parts  => { realms => { required => 1 } },
        paths  => [
            [ { realms => 2 }, "_shield", "realm", "{realms}", "_clear_cache" ],
        ],
        qs => { filter_path => "list", usernames => "string" },
    },

    'shield.clear_cached_roles' => {
        doc    => "",
        method => "PUT",
        parts  => { name => { required => 1 } },
        paths =>
            [ [ { name => 2 }, "_shield", "role", "{name}", "_clear_cache" ] ],
        qs => { filter_path => "list" },
    },

    'shield.delete_role' => {
        doc    => "",
        method => "DELETE",
        parts  => { name => { required => 1 } },
        paths  => [ [ { name => 2 }, "_shield", "role", "{name}" ] ],
        qs => { filter_path => "list" },
    },

    'shield.delete_user' => {
        doc    => "",
        method => "DELETE",
        parts  => { username => { required => 1 } },
        paths  => [ [ { username => 2 }, "_shield", "user", "{username}" ] ],
        qs => { filter_path => "list" },
    },

    'shield.get_role' => {
        doc   => "",
        parts => { name => {} },
        paths => [
            [ { name => 2 }, "_shield", "role", "{name}" ],
            [ {}, "_shield", "role" ],
        ],
        qs => { filter_path => "list" },
    },

    'shield.get_user' => {
        doc   => "",
        parts => { username => { multi => 1 } },
        paths => [
            [ { username => 2 }, "_shield", "user", "{username}" ],
            [ {}, "_shield", "user" ],
        ],
        qs => { filter_path => "list" },
    },

    'shield.put_role' => {
        body   => { required => 1 },
        doc    => "",
        method => "PUT",
        parts => { name => { required => 1 } },
        paths => [ [ { name => 2 }, "_shield", "role", "{name}" ] ],
        qs => { filter_path => "list" },
    },

    'shield.put_user' => {
        body   => { required => 1 },
        doc    => "",
        method => "PUT",
        parts => { username => { required => 1 } },
        paths => [ [ { username => 2 }, "_shield", "user", "{username}" ] ],
        qs => { filter_path => "list" },
    },

    'watcher.ack_watch' => {
        doc    => "appendix-api-ack-watch",
        method => "PUT",
        parts => { action_id => { multi => 1 }, watch_id => { required => 1 } },
        paths => [
            [   { action_id => 3, watch_id => 2 }, "_watcher",
                "watch",       "{watch_id}",
                "{action_id}", "_ack",
            ],
            [ { watch_id => 2 }, "_watcher", "watch", "{watch_id}", "_ack" ],
        ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'watcher.activate_watch' => {
        doc    => "",
        method => "PUT",
        parts  => { watch_id => { required => 1 } },
        paths  => [
            [   { watch_id => 2 }, "_watcher",
                "watch", "{watch_id}",
                "_activate",
            ],
        ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'watcher.deactivate_watch' => {
        doc    => "",
        method => "PUT",
        parts  => { watch_id => { required => 1 } },
        paths  => [
            [   { watch_id => 2 }, "_watcher",
                "watch", "{watch_id}",
                "_deactivate",
            ],
        ],
        qs => { filter_path => "list", master_timeout => "time" },
    },

    'watcher.delete_watch' => {
        doc    => "appendix-api-delete-watch",
        method => "DELETE",
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs     => {
            filter_path    => "list",
            force          => "boolean",
            master_timeout => "time"
        },
    },

    'watcher.execute_watch' => {
        body   => {},
        doc    => "appendix-api-execute-watch",
        method => "PUT",
        parts  => { id => {} },
        paths  => [
            [ { id => 2 }, "_watcher", "watch", "{id}", "_execute" ],
            [ {}, "_watcher", "watch", "_execute" ],
        ],
        qs => { debug => "boolean", filter_path => "list" },
    },

    'watcher.get_watch' => {
        doc   => "appendix-api-get-watch",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs => { filter_path => "list" },
    },

    'watcher.info' => {
        doc   => "appendix-api-info",
        parts => {},
        paths => [ [ {}, "_watcher" ] ],
        qs => { filter_path => "list" },
    },

    'watcher.put_watch' => {
        body   => { required => 1 },
        doc    => "appendix-api-put-watch",
        method => "PUT",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs => {
            active         => "boolean",
            filter_path    => "list",
            master_timeout => "time"
        },
    },

    'watcher.restart' => {
        doc    => "appendix-api-service",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_restart" ] ],
        qs => { filter_path => "list" },
    },

    'watcher.start' => {
        doc    => "appendix-api-service",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_start" ] ],
        qs => { filter_path => "list" },
    },

    'watcher.stats' => {
        doc   => "appendix-api-stats",
        parts => { metric => {} },
        paths => [
            [ { metric => 2 }, "_watcher", "stats", "{metric}" ],
            [ {}, "_watcher", "stats" ],
        ],
        qs => { filter_path => "list" },
    },

    'watcher.stop' => {
        doc    => "appendix-api-service",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_stop" ] ],
        qs => { filter_path => "list" },
    },

#=== AUTOGEN - END ===
);
__PACKAGE__->_qs_init( \%API );
1;

__END__

# ABSTRACT: This class contains the spec for the Elasticsearch XPack APIs for 2.x

