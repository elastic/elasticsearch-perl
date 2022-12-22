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

package Search::Elasticsearch::Client::8_0::Direct::SQL;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('sql');

1;

__END__

# ABSTRACT: Plugin providing SQL for Search::Elasticsearch 8.x

=head1 SYNOPSIS

    my $response = $es->sql->query( body => {...} )

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<sql>
namespace, to support the
L<SQL APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-rest.html>.

The full documentation for the SQL feature is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/xpack-sql.html>

=head1 GENERAL METHODS

=head2 C<query()>

    $response = $es->sql->query(
        body    => {...} # required
    )

The C<query()> method executes an SQL query and returns the results.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<format>,
    C<human>

See the L<query docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-rest.html>
for more information.

=head2 C<translate()>

    $response = $es->sql->translate(
        body    => {...} # required
    )

The C<translate()> method takes an SQL query and returns the query DSL which would be executed.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<translate docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-translate.html>
for more information.

=head2 C<clear_cursor()>

    $response = $es->sql->clear_cursor(
        body    => {...} # required
    )

The C<clear_cursor()> method cleans up an ongoing scroll request.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<query docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-rest.html>
for more information.

