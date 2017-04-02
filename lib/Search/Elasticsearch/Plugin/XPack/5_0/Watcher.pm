package Search::Elasticsearch::Plugin::XPack::5_0::Watcher;

use Moo;
with 'Search::Elasticsearch::Plugin::XPack::5_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('xpack.watcher');

1;

# ABSTRACT: Plugin providing Watcher API for Search::Elasticsearch 5.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['XPack']
    );

    my $response = $es->watcher->info();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<watcher>
namespace, to support the API for the
L<Watcher|https://www.elastic.co/products/watcher> plugin for Elasticsearch.
In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['Watcher']
    );

    my $response = $es->watcher->stats();

=head1 METHODS

The full documentation for the Watcher plugin is available here:
L<https://www.elastic.co/guide/en/x-pack/current/xpack-alerting.html>

=head2 C<put_watch()>

    $response = $es->watcher->put_watch(
        id    => $watch_id,     # required
        body  => {...}          # required
    );

The C<put_watch()> method is used to register a new watcher or to update
an existing watcher.

See the L<put_watch docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-put-watch.html>
for more information.

Query string parameters:
    C<active>,
    C<error_trace>,
    C<human>,
    C<master_timeout>

=head2 C<get_watch()>

    $response = $es->watcher->get_watch(
        id    => $watch_id,     # required
    );

The C<get_watch()> method is used to retrieve a watch by ID.

See the L<get_watch docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-get-watch.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_watch()>

    $response = $es->watcher->delete_watch(
        id    => $watch_id,     # required
    );

The C<delete_watch()> method is used to delete a watch by ID.

Query string parameters:
    C<error_trace>,
    C<force>,
    C<human>,
    C<master_timeout>

See the L<delete_watch docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-delete-watch.html>
for more information.

=head2 C<execute_watch()>

    $response = $es->watcher->execute_watch(
        id    => $watch_id,     # optional
        body  => {...}          # optional
    );

The C<execute_watch()> method forces the execution of a previously
registered watch.  Optional parameters may be passed in the C<body>.

Query string parameters:
    C<debug>,
    C<error_trace>,
    C<human>

See the L<execute_watch docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-execute-watch.html>
for more information.

=head2 C<ack_watch()>

    $response = $es->watcher->ack_watch(
        watch_id => $watch_id,                  # required
        action_id => $action_id | \@action_ids  # optional
    );

The C<ack_watch()> method is used to manually throttle the execution of
a watch.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>

See the L<ack_watch docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-ack-watch.html>
for more information.

=head2 C<activate_watch()>

    $response = $es->watcher->activate_watch(
        watch_id => $watch_id,                  # required
    );

The C<activate_watch()> method is used to activate a deactive watch.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>

See the L<activate_watch docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-activate-watch.html>
for more information.

=head2 C<deactivate_watch()>

    $response = $es->watcher->deactivate_watch(
        watch_id => $watch_id,                  # required
    );

The C<deactivate_watch()> method is used to deactivate an active watch.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>

See the L<deactivate_watch docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-deactivate-watch.html>
for more information.

=head2 C<stats()>

    $response = $es->watcher->stats(
        metric => $metric       # optional
    );

The C<stats()> method returns information about the status of the watcher plugin.

See the L<stats docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-stats.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<stop()>

    $response = $es->watcher->stop();

The C<stop()> method stops the watcher service if it is running.

See the L<stop docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-stop.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<start()>

    $response = $es->watcher->start();

The C<start()> method starts the watcher service if it is not already running.

See the L<start docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-start.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<restart()>

    $response = $es->watcher->restart();

The C<restart()> method stops then starts the watcher service.

See the L<restart docs|https://www.elastic.co/guide/en/x-pack/current/watcher-api-restart.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>



