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

# ABSTRACT: you can use the following APIs to perform transform operations.


=head1 SYNOPSIS

    my $response = $es->transform->put_transform();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<transform>
namespace, to support the
L<Transform APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/transform-apis.html>.

=head1 GENERAL METHODS

=head2 C<put_transform()>

    my $response = $es->transform->put_transform(
        transform_id => 'my_id',
        body => {
            # ...
        }
    );


The C<put_transform()> defines a transform, which copies data from source indices, transforms it,
and persists it into an entity-centric destination index.

=head2 C<get_transform()>

    $response = $es->transform->get_transform(
        transform_id => 'my_id'
    );

The C<get_transforms()> retrieves configuration information for transforms..

=head2 C<delete_transform()>

    $response = $es->transform->delete_transform(
        transform_id => 'my_id'
    );

The C<delete_transform()> deletes an existing transform.

=head2 C<get_transform_stats()>

    $response = $es->transform->get_transform_stats(
        transform_id => 'my_id'
    );

The C<get_transform_stats()> retrieves usage information for transforms.

=head2 C<preview_transform()>

    $response = $es->transform->preview_transform(
        body => {
            # ...
        }
    );

The C<preview_transform()> previews a transforms. This API generates a preview 
of the results that you will get when you run the create transforms API 
with the same configuration. It returns a maximum of 100 results.

=head2 C<start_transform()>

    $response = $es->transform->start_transform(
         transform_id => 'my_id'
    );

The C<start_transform()> starts one or more transforms.

=head2 C<stop_transform()>

    $response = $es->transform->stop_transform(
         transform_id => 'my_id'
    );

The C<stop_transform()> stops one or more transforms.

=head2 C<update_transform()>

    $response = $es->transform->update_transform(
        transform_id => 'my_id',
        body => {
            # ...
        }
    );

The C<update_transform()> updates certain properties of a transform.