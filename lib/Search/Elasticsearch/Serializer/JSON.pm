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

package Search::Elasticsearch::Serializer::JSON;

use Moo;
use JSON::MaybeXS 1.002002 ();

has 'JSON' => ( is => 'ro', default => sub { JSON::MaybeXS->new->utf8(1) } );

with 'Search::Elasticsearch::Role::Serializer::JSON';
use namespace::clean;

1;

# ABSTRACT: The default JSON Serializer, using JSON::MaybeXS

=head1 SYNOPSIS

    $e = Search::Elasticsearch(
        # serializer => 'JSON'
    );

=head1 DESCRIPTION

This default Serializer class chooses between:

=over

=item * L<Cpanel::JSON::XS>

=item * L<JSON::XS>

=item * L<JSON::PP>

=back

First it checks if either L<Cpanel::JSON::XS> or L<JSON::XS> is already
loaded and, if so, uses the appropriate backend.  Otherwise it tries
to load L<Cpanel::JSON::XS>, then L<JSON::XS> and finally L<JSON::PP>.

If you would prefer to specify a particular JSON backend, then you can
do so by using one of these modules:

=over

=item * L<Search::Elasticsearch::Serializer::JSON::Cpanel>

=item * L<Search::Elasticsearch::Serializer::JSON::XS>

=item * L<Search::Elasticsearch::Serializer::JSON::PP>

=back

See their documentation for details.

