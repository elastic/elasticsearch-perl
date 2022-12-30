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

package Search::Elasticsearch::Client::8_0::Direct::SSL;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('ssl');

1;

__END__

# ABSTRACT: Plugin providing SSL for Search::Elasticsearch 8.x

=head1 SYNOPSIS

    my $response = $es->ssl->certificates()

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<ssl>
namespace, to support the
L<SSL APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-ssl.html>.

=head1 GENERAL METHODS

=head2 C<certificates()>

    $response = $es->ssl->certificates()

The C<certificates()> method returns all the certificate information on a single node of Elasticsearch.
