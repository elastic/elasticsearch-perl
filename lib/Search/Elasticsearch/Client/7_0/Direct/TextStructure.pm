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

package Search::Elasticsearch::Client::7_0::Direct::TextStructure;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('text_structure');

1;

__END__

# ABSTRACT: Plugin providing TextStructure for Search::Elasticsearch 7.x

NOTE: this API is experimental and may be changed or removed completely in a future release 

=head1 SYNOPSIS

    my $response = $es->text_structure->find_structure(
        # values here
    );

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<text_structure>
namespace, to support the API for the Text Structure plugin for Elasticsearch.

=head1 METHODS

The full documentation for the Text Structure plugin is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/find-structure.html>
