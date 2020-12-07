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

package Search::Elasticsearch::Client::7_0::Direct::AsyncSearch;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('async_search');

1;

__END__

# ABSTRACT: The async search API let you asynchronously execute a search request,
# monitor its progress, and retrieve partial results as they become available.

=head1 SYNOPSIS

    my $response = $es->async_search->get(
        'id' => 'my_id'
    );

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<async_search>
namespace, to support the
L<Async Search APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/async-search.html>.

=head1 GENERAL METHODS

=head2 C<get()>

    my $response = $es->async_search->get(
        id => 'my_id'
    );


The C<get()> retrieves the results of a previously submitted async search request given its id. 
If the Elasticsearch security features are enabled. the access to the results of a specific
async search is restricted to the user that submitted it in the first place.

=head2 C<submit()>

    $response = $es->async_search->submit(
        index => 'my_index',
        body => {
            # ...
        }
    );

The C<submit()> method executes a search request asynchronously. It accepts the same parameters
and request body as the search API.

=head2 C<delete()>

    $response = $es->async_search->delete(
        id => 'my_id'
    );

The C<delete()> method delete an async search by ID. If the search is still running, the search
request will be cancelled. Otherwise, the saved search results are deleted.


