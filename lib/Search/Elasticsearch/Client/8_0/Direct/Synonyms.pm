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

package Search::Elasticsearch::Client::8_0::Direct::Synonyms;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('synonyms');

1;

__END__

# ABSTRACT: The synonyms management API provides a convenient way
to define and manage synonyms in an internal system index. 
Related synonyms can be grouped in a "synonyms set". 
Create as many synonym sets as you need.

=head2 DESCRIPTION

The full documentation for Synonyms API is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/synonyms-apis.html>

=head1 FOLLOW METHODS

=head2 C<follow()>

    my $response = $es->synonyms->put_synonym(
        'id' => 'my-synonyms-set',
        'body'  => {
            synonyms_set' => [
                {
                    'id' => 'test-1',
                    'synonyms' => 'hello, hi'
                },
                {
                    'synonyms' => 'bye, goodbye'
                },
                {
                    'id' => 'test-2',
                    'synonyms' => 'test => check'
                },
            ]
        }
    );

An introduction to synonyms in Elasticsearch is available here:
L<https://www.elastic.co/blog/update-synonyms-elasticsearch-introducing-synonyms-api>