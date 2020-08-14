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

package Search::Elasticsearch::Client::6_0::Direct::ILM;

use Moo;
with 'Search::Elasticsearch::Client::6_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use Search::Elasticsearch::Util qw(parse_params);
use namespace::clean;
__PACKAGE__->_install_api('ilm');

1;

__END__

# ABSTRACT: Plugin providing index lifecycle management APIs for Search::Elasticsearch 6.x

=head2 DESCRIPTION

This module provides methods to use the index lifecycle management feature.

The full documentation for ILM is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/index-lifecycle-management.html>

=head1 POLICY METHODS

=head2 C<put_lifecycle()>

    $response = $es->ilm->put_lifecycle(
        policy  => $policy  # required
        body    => {...}    # required
    )

The C<put_lifecycle()> method creates or updates a lifecycle policy.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM put_lifecycle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-put-lifecycle.html>
for more information.

=head2 C<put_lifecycle()>

    $response = $es->ilm->put_lifecycle(
        policy  => $policy  # required
        body    => {...}    # required
    )

The C<put_lifecycle()> method creates or updates a lifecycle policy.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM put_lifecycle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-put-lifecycle.html>
for more information.


=head2 C<get_lifecycle()>

    $response = $es->ilm->get_lifecycle(
        policy  => $policy  # required
    )

The C<get_lifecycle()> method retrieves the specified policy

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM get_lifecycle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-get-lifecycle.html>
for more information.

=head2 C<delete_lifecycle()>

    $response = $es->ilm->delete_lifecycle(
        policy  => $policy  # required
    )

The C<delete_lifecycle()> method deletes the specified policy

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM delete_lifecycle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-remove-lifecycle.html>
for more information.

=head1 INDEX MANAGEMENT METHODS

=head2 C<move_to_step()>

    $response = $es->ilm->move_to_step(
        index  => $index,       # required
        body   => {...}         # required
    )

The C<move_to_step()> method triggers execution of a specific step in the lifecycle policy.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM move_to_step docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-move-to-step.html>
for more information.


=head2 C<retry()>

    $response = $es->ilm->retry(
        index  => $index,       # required
    )

The C<retry()> method retries executing the policy for an index that is in the ERROR step.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM retry docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-retry.html>
for more information.


=head2 C<remove_lifecycle()>

    $response = $es->ilm->remove_lifecycle(
        index  => $index  # required
    )

The C<remove_lifecycle()> method removes a lifecycle from the specified index.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM remove_lifecycle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-remove-lifecycle.html>
for more information.

=head2 C<explain_lifecycle()>

    $response = $es->ilm->explain_lifecycle(
        index  => $index  # required
    )

The C<explain_lifecycle()> method returns information about the index’s current lifecycle state.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM explain_lifecycle docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-explain-lifecycle.html>
for more information.


=head1 OPERATION MANAGEMENT APIS

=head2 C<status()>

    $response = $es->ilm->status;

The C<status()> method returns the current operating mode for ILM.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM status docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-get-status.html>
for more information.

=head2 C<start()>

    $response = $es->ilm->start;

The C<start()> method starts the index lifecycle management process.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM start docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-start.html>
for more information.

=head2 C<stop()>

    $response = $es->ilm->stop;

The C<stop()> method stops the index lifecycle management process.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<ILM stop docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ilm-stop.html>
for more information.
