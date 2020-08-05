# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Client::7_0::Direct::DataFrame;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('data_frame');

1;

__END__

# ABSTRACT: Plugin providing Transform API for Search::Elasticsearch 7.x

=head1 SYNOPSIS

    my $response = $es->data_frame->explore(...);

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<data_frame>
namespace, to support the API for the
L<Transform|https://www.elastic.co/guide/en/elasticsearch/reference/7.3/transform-apis.html> plugin for Elasticsearch.

=head1 METHODS

The full documentation for the Transform plugin is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/7.3/transform-apis.html>

=head2 C<explore()>

    $response = $es->data_frame->put_data_frame_transform(
        transform_id => $transform_id,
        body  => {...}
    );

The C<put_data_frame_transform()> instantiates a transform.
