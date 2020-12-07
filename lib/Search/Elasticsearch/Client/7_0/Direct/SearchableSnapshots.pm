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

package Search::Elasticsearch::Client::7_0::Direct::SearchableSnapshots;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('searchable_snapshots');

1;

__END__

# ABSTRACT: you can use the following APIs to perform searchable snapshots operations.
#
# WARNING: This functionality is in beta and is subject to change. 
# The design and code is less mature than official GA features and is being provided
# as-is with no warranties. Beta features are not subject to the support SLA of official
# GA features.

=head1 SYNOPSIS

    my $response = $es->searchable_snapshots->stats();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<searchable_snapshots>
namespace, to support the
L<Searchable Snapshot APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/searchable-snapshots-apis.html>.

=head1 GENERAL METHODS

=head2 C<stats()>

    my $response = $es->searchable_snapshots->stats();


The C<stats()> retrieves various statistics about searchable snapshots.

=head2 C<repository_stats()>

    $response = $es->searchable_snapshots->repository_stats(
        repository => 'my_repository'
    );

The C<repository_stats())> is deprecated: replaced by the Repositories Metering API.

=head2 C<mount()>

    $response = $es->searchable_snapshots->mount(
        repository => 'my_repository'
        snapshot => 'my_spanshot',
        body => {
            # ...
        }
    );

The C<mount()> method mount a snapshot as a searchable index.

=head2 C<clear_cache()>

    $response = $es->searchable_snapshots->clear_cache();

The C<clear_cache()> method clear the cache of searchable snapshots.
