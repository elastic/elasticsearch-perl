package Search::Elasticsearch::Plugin::Watcher;

use Moo;
with 'Search::Elasticsearch::Plugin::Watcher::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('watcher');

use Search::Elasticsearch 1.99 ();

our $VERSION = '1.99';

#===================================
sub _init_plugin {
#===================================
    my ( $class, $params ) = @_;

    Moo::Role->apply_roles_to_object( $params->{client},
        qw(Search::Elasticsearch::Plugin::Watcher::Namespace) );
}

package Search::Elasticsearch::Plugin::Watcher::Namespace;

use Moo::Role;

has 'watcher' => ( is => 'lazy', init_arg => undef );

sub _build_watcher {
    shift->_build_namespace('+Search::Elasticsearch::Plugin::Watcher');
}

1;

__END__

# ABSTRACT: Plugin providing Watcher API for Search::Elasticsearch

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['Watcher']
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

    my $response = $es->watcher->info();

It works with the L<version 1.x|Search::Elasticsearch::Client::2_0::Direct>
and L<version 2.x|Search::Elasticsearch::Client::1_0::Direct> clients, and
can be used both in L<Search::Elasticsearch> and in
L<Search::Elasticsearch::Async>.

=head1 METHODS

The full documentation for the Watcher plugin is available here:
L<http://www.elastic.co/guide/en/watcher/current/>

=head2 C<put_watch()>

    $response = $es->watcher->put_watch(
        id    => $watch_id,     # required
        body  => {...}          # required
    );

The C<put_watch()> method is used to register a new watcher or to update
an existing watcher.

See the L<put_watch docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-put-watch>
for more information.

=head2 C<get_watch()>

    $response = $es->watcher->get_watch(
        id    => $watch_id,     # required
    );

The C<get_watch()> method is used to retrieve a watch by ID.

See the L<get_watch docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-get-watch>
for more information.

=head2 C<delete_watch()>

    $response = $es->watcher->delete_watch(
        id    => $watch_id,     # required
    );

The C<delete_watch()> method is used to delete a watch by ID.

Query string parameters:
    C<force>,
    C<master_timeout>

See the L<delete_watch docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-delete-watch>
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
    C<master_timeout>

See the L<execute_watch docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-execute-watch>
for more information.

=head2 C<ack_watch()>

    $response = $es->watcher->ack_watch(
        watch_id => $watch_id,                  # required
        action_id => $action_id | \@action_ids  # optional
    );

The C<ack_watch()> method is used to manually throttle the execution of
a watch.

Query string parameters:
    C<master_timeout>

See the L<ack_watch docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-ack-watch>
for more information.
for more information.

=head2 C<info()>

    $response = $es->watcher->info();

The C<info()> method returns basic information about the watcher plugin
that is installed.

See the L<info docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-info>
for more information.

=head2 C<stats()>

    $response = $es->watcher->stats(
        metric => $metric       # optional
    );

The C<stats()> method returns information about the status of the watcher plugin.

See the L<stats docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-stats>
for more information.

=head2 C<stop()>

    $response = $es->watcher->stop();

The C<stop()> method stops the watcher service if it is running.

See the L<stop docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-stop>
for more information.

=head2 C<start()>

    $response = $es->watcher->start();

The C<start()> method starts the watcher service if it is not already running.

See the L<start docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-start>
for more information.


=head2 C<restart()>

    $response = $es->watcher->restart();

The C<restart()> method stops then starts the watcher service.

See the L<restart docs|http://www.elastic.co/guide/en/watcher/current/api-rest.html#api-rest-restart>
for more information.



