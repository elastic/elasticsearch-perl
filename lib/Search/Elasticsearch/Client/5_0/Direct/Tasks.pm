package Search::Elasticsearch::Client::5_0::Direct::Tasks;

use Moo;
with 'Search::Elasticsearch::Client::5_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('tasks');

1;

__END__

# ABSTRACT: A client for accessing the Task Management API

=head1 DESCRIPTION

This module provides methods to access the Task Management API, such as listing
tasks and cancelling tasks.

It does L<Search::Elasticsearch::Role::Client::Direct>.

=head1 METHODS


=head2 C<list()>

    $response = $e->tasks->list(
        task_id => $task_id  # optional
    );

The C<list()> method returns all running tasks or, if a C<task_id> is specified, info
about that task.

Query string parameters:
    C<actions>,
    C<detailed>,
    C<node_id>,
    C<parent_node>,
    C<parent_task>,
    C<wait_for_completion>

See the L<task management docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/tasks.html>
for more information.

=head2 C<cancel()>

    $response = $e->tasks->cancel(
        task_id => $task_id  # option
    );

The C<cancel()> method attempts to cancel the specified C<task_id> or multiple tasks.

Query string parameters:
    C<actions>,
    C<node_id>,
    C<parent_node>,
    C<parent_task>

See the L<task management docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/tasks.html>
for more information.

