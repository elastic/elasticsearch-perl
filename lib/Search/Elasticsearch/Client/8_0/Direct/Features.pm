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

package Search::Elasticsearch::Client::8_0::Direct::Features;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('features');

1;

__END__

# ABSTRACT: Features API for Search::Elasticsearch 8.x


=head1 SYNOPSIS

    my $response = $es->features->get_features(...);

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<features>
namespace, to support the API for the
L<Features|https://www.elastic.co/guide/en/elasticsearch/reference/current/features-apis.html> plugin for Elasticsearch.

=head1 METHODS

The full documentation for the Features plugin is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/features-apis.html>

=head2 C<explore()>

    $response = $es->features->get_features();

The C<get_features()> method Gets a list of features which can be included in snapshots
using the feature_states field when creating a snapshot.

See the L<get_features|https://www.elastic.co/guide/en/elasticsearch/reference/current/get-features-api.html>
for more information.
