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

package Search::Elasticsearch::Client::8_0::Direct::Simulate;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('simulate');

1;

__END__

# ABSTRACT: Executes ingest pipelines against a set of provided
documents, optionally with substitute pipeline definitions. 
This API is meant to be used for troubleshooting or pipeline 
development, as it does not actually index any data into Elasticsearch.

=head2 DESCRIPTION

The full documentation for Simulate ingest API is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/master/simulate-ingest-api.html>

=head1 FOLLOW METHODS

=head2 C<follow()>

    my $response = $es->simulate->ingest(
        'index' => 'test',
        'body'  => {
            'docs' => [
                {
                    '_id' => '123',
                    '_source' => {
                        'foo': 'bar'
                    }
                },
                {
                    '_id' => '456',
                    '_source' => {
                        'foo': 'baz'
                    }
                },
            ]
        }
    );