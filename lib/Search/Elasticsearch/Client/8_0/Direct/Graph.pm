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

package Search::Elasticsearch::Client::8_0::Direct::Graph;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('graph');

1;

__END__

# ABSTRACT: Plugin providing Graph API for Search::Elasticsearch 8.x

=head1 SYNOPSIS

    my $response = $es->graph->explore(...);

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<graph>
namespace, to support the API for the
L<Graph|https://www.elastic.co/guide/en/x-pack/current/xpack-graph.html> plugin for Elasticsearch.

=head1 METHODS

The full documentation for the Graph plugin is available here:
L<https://www.elastic.co/guide/en/graph/current/index.html>

=head2 C<explore()>

    $response = $es->graph->explore(
        index => $index | \@indices,        # optional
        type  => $type  | \@types,          # optional
        body  => {...}
    )

The C<explore()> method allows you to discover vertices and connections which relate
to your query.

See the L<explore docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/graph-explore-api.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<routing>,
    C<timeout>
