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

package Search::Elasticsearch::Client::7_0::Direct::Transform;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('transform');

1;

__END__

# ABSTRACT: Transform feature of Search::Elasticsearch 7.x

=head2 DESCRIPTION

The full documentation for Transform feature is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/transform-apis.html>

=head1 FOLLOW METHODS

=head2 C<follow()>

    my $response = $es->transform->get_transform(
        'transform_id' => $transform_id
    );

