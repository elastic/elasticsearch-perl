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

package Search::Elasticsearch::Client::7_0::Direct::Slm;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('slm');

1;

__END__

# ABSTRACT: Plugin providing Snapshot Lifecycle Management (SLM) for Search::Elasticsearch 7.x

=head1 SYNOPSIS

    my $response = $es->slm->status()

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<slm>
namespace, to support the
L<SLM APIs|https://www.elastic.co/guide/en/elasticsearch/reference/master/snapshot-lifecycle-management-api.html>.

=head1 GENERAL METHODS

=head2 C<get_status()>

    $response = $es->slm->get_status()

The C<status()> method retrieves the status of snapshot lifecycle management (SLM).

=head2 C<get_stats()>

    $response = $es->slm->get_stats()

The C<get_stats()> method returns global and policy-level statistics about actions
taken by snapshot lifecycle management.

=head2 C<get_lifecycle()>

    $response = $es->slm->get_lifecycle()

The C<get_lifecycle()> method retrieves one or more snapshot lifecycle policy definitions and
information about the latest snapshot attempts.

=head2 C<put_lifecycle()>

    $response = $es->slm->put_lifecycle()

The C<put_lifecycle()> method creates or updates a snapshot lifecycle policy.

=head2 C<delete_lifecycle()>

    $response = $es->slm->delete_lifecycle()

The C<delete_lifecycle()> method deletes an existing snapshot lifecycle policy.

=head2 C<execute_lifecycle()>

    $response = $es->slm->execute_lifecycle()

The C<execute_lifecycle()> method immediately creates a snapshot according to the lifecycle
policy, without waiting for the scheduled time.

=head2 C<(execute_retention())>

    $response = $es->slm->execute_retention()

The C<execute_retention()> method deletes any snapshots that are expired according
to the policy’s retention rules.

=head2 C<start()>

    $response = $es->slm->start()

The C<start()> method turns on snapshot lifecycle management (SLM).

=head2 C<stop()>

    $response = $es->slm->stop()

The C<stop()> method turns off snapshot lifecycle management (SLM).