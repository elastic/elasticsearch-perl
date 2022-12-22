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

package Search::Elasticsearch::Client::8_0::Direct::Migration;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('migration');

1;

__END__

# ABSTRACT: Plugin providing Migration API for Search::Elasticsearch 8.x

=head1 SYNOPSIS

    my $response = $es->migration->deprecations();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<migration>
namespace, to support the API
L<Migration APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api.html>.

=head1 METHODS

The full documentation for the Migration APIs is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api.html>

=head2 C<deprecations()>

    $response = $es->migration->deprecations(
        index => $index      # optional
    )

The C<deprecations()> API is to be used to retrieve information about different cluster, node,
and index level settings that use deprecated features that will be removed or changed in the
next major version.

See the L<deprecations docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api-deprecation.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_assistance()>

    $response = $es->migration->get_assistance(
        index => $index | \@indices      # optional
    )

The C<get_assistance()> API analyzes existing indices in the cluster and returns the information
about indices that require some changes before the cluster can be upgraded to the next major version.

See the L<get_assistance docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api-assistance.html>
for more information.

Query string parameters:
    C<allow_no_indices>,
    C<error_trace>,
    C<expand_wildcards>,
    C<human>,
    C<ignore_unavailable>

=head2 C<upgrade()>

    $response = $es->migration->upgrade(
        index => $index       # required
    )

The C<upgrade()> API performs the upgrade of internal indices to make them compatible with the
next major version.

See the L<upgrade() docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/migration-api-upgrade.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<wait_for_completion>



