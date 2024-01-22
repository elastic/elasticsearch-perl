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

package Search::Elasticsearch::Client::8_0::Async;

our $VERSION='8.12';
use Search::Elasticsearch::Client::8_0 8.12 ();

1;

__END__

# ABSTRACT: Thin async client with full support for Elasticsearch 8.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::8_0::Async> package provides a client
compatible with Elasticsearch 8.x.  It should be used in conjunction
with L<Search::Elasticsearch::Async> as follows:

    $e = Search::Elasticsearch::Async->new(
        client => "8_0::Direct"
    );

See L<Search::Elasticsearch::Client::8_0::Direct> for documentation
about how to use the client itself.

=head1 PREVIOUS VERSIONS OF ELASTICSEARCH

This version of the client supports the Elasticsearch 7.0 branch,
which is not backwards compatible with earlier branches.

If you need to talk to a version of Elasticsearch before 7.0.0, please
install one of the following packages:

=over

=item *

L<Search::Elasticsearch::Client::7_0::Async>

=item *

L<Search::Elasticsearch::Client::6_0::Async>

=item *

L<Search::Elasticsearch::Client::5_0::Async>

=item *

L<Search::Elasticsearch::Client::2_0::Async>

=item *

L<Search::Elasticsearch::Client::1_0::Async>

=item *

L<Search::Elasticsearch::Client::0_90::Async>

=back
