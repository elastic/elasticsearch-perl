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

package Search::Elasticsearch::Client::8_0::Direct::Connector;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('connector');

1;

__END__

# ABSTRACT: A client for create and manage Elastic connectors

=head1 DESCRIPTION

The connector and sync jobs API provides a convenient way to create
and manage Elastic connectors and sync jobs in an internal index.

This API provides an alternative to relying solely on Kibana UI
for connector and sync job management. The API comes with a set of
validations and assertions to ensure that the state representation 
in the internal index remains valid.

The full documentation for Eql feature is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/master/connector-apis.html>

It does L<Search::Elasticsearch::Role::Client::Direct>.

=head1 METHODS

=head2 C<put()>

    $response = $e->connector->put(
        connector_id => "my-connector",
        body => {
            index_name => "search-google-drive",
            name => "My Connector",
            service_type => "google_drive" 
        }
    );

The C<put()> method create a connector.
