package Search::Elasticsearch::Plugin::Watcher::API;

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

    'watcher.ack_watch' => {
        doc    => "appendix-api-ack-watch",
        method => "PUT",
        parts =>
            { action_id => { multi => 1 }, watch_id => { required => 1 } },
        paths => [
            [   { action_id => 3, watch_id => 2 }, "_watcher",
                "watch",       "{watch_id}",
                "{action_id}", "_ack",
            ],
            [ { watch_id => 2 }, "_watcher", "watch", "{watch_id}", "_ack" ],
        ],
        qs => ["master_timeout"],
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
        qs => ["master_timeout"],
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
        qs => ["master_timeout"],
    },

    'watcher.delete_watch' => {
        doc    => "appendix-api-delete-watch",
        method => "DELETE",
        parts  => { id => { required => 1 } },
        paths  => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs => [ "force", "master_timeout" ],
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
        qs => ["debug"],
    },

    'watcher.get_watch' => {
        doc   => "appendix-api-get-watch",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs    => [],
    },

    'watcher.info' => {
        doc   => "appendix-api-info",
        parts => {},
        paths => [ [ {}, "_watcher" ] ],
        qs    => [],
    },

    'watcher.put_watch' => {
        body   => { required => 1 },
        doc    => "appendix-api-put-watch",
        method => "PUT",
        parts => { id => { required => 1 } },
        paths => [ [ { id => 2 }, "_watcher", "watch", "{id}" ] ],
        qs => [ "active", "master_timeout" ],
    },

    'watcher.restart' => {
        doc    => "appendix-api-service",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_restart" ] ],
        qs     => [],
    },

    'watcher.start' => {
        doc    => "appendix-api-service",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_start" ] ],
        qs     => [],
    },

    'watcher.stats' => {
        doc   => "appendix-api-stats",
        parts => { metric => {} },
        paths => [
            [ { metric => 2 }, "_watcher", "stats", "{metric}" ],
            [ {}, "_watcher", "stats" ],
        ],
        qs => [],
    },

    'watcher.stop' => {
        doc    => "appendix-api-service",
        method => "PUT",
        parts  => {},
        paths  => [ [ {}, "_watcher", "_stop" ] ],
        qs     => [],
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
