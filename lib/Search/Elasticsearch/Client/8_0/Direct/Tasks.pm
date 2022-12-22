# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

package Search::Elasticsearch::Client::8_0::Direct::Tasks;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
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
    C<error_trace>,
    C<group_by>,
    C<human>,
    C<nodes>,
    C<parent_task_id>,
    C<timeout>,
    C<wait_for_completion>

See the L<task management docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/tasks.html>
for more information.

=head2 C<get()>

    $response = $e->tasks->get(
        task_id => $task_id  # required
    );

The C<get()> method returns the task with the specified ID.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<wait_for_completion>

See the L<task management docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/tasks.html>
for more information.

=head2 C<cancel()>

    $response = $e->tasks->cancel(
        task_id => $task_id  # required
    );

The C<cancel()> method attempts to cancel the specified C<task_id> or multiple tasks.

Query string parameters:
    C<actions>,
    C<error_trace>,
    C<human>,
    C<nodes>,
    C<parent_task_id>,
    C<timeout>

See the L<task management docs|http://www.elastic.co/guide/en/elasticsearch/reference/current/tasks.html>
for more information.

