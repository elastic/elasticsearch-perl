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

package Search::Elasticsearch::Client::6_0;

our $VERSION='7.110';
use Search::Elasticsearch 7.00 ();

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch 6.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::6_0> package provides a client
compatible with Elasticsearch 6.x.  It should be used in conjunction
with L<Search::Elasticsearch> as follows:

    $e = Search::Elasticsearch->new(
        client => "6_0::Direct"
    );

See L<Search::Elasticsearch::Client::6_0::Direct> for documentation
about how to use the client itself.

=head1 PREVIOUS VERSIONS OF ELASTICSEARCH

This version of the client supports the Elasticsearch 6.0 branch,
which is not backwards compatible with earlier branches.

If you need to talk to a version of Elasticsearch before 6.0.0, please
install one of the following packages:

=over

=item *

L<Search::Elasticsearch::Client::5_0>

=item *

L<Search::Elasticsearch::Client::2_0>

=item *

L<Search::Elasticsearch::Client::1_0>

=item *

L<Search::Elasticsearch::Client::0_90>

=back
