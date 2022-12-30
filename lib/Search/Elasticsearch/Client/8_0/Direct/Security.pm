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

package Search::Elasticsearch::Client::8_0::Direct::Security;

use Moo;
with 'Search::Elasticsearch::Client::8_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('security');

1;

__END__

# ABSTRACT: Plugin providing Security API for Search::Elasticsearch 8.x

=head1 SYNOPSIS

    my $response = $es->security->authenticate();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<security>
namespace, to support the
L<Security APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api.html>.

The full documentation for the Security feature is available here:
L<https://www.elastic.co/guide/en/x-pack/current/xpack-security.html>

=head1 GENERAL METHODS

=head2 C<authenticate()>

    $response = $es->security->authenticate()

The C<authenticate()> method checks that the C<userinfo> is correct and returns
a list of which roles are assigned to the user.

See the L<authenticate docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-authenticate.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<clear_cached_realms()>

    $response = $es->security->clear_cached_realms(
        realms => $realms       # required  (comma-separated string)
    );

The C<clear_cached_realms()> method clears the caches for the specified realms

Query string parameters:
    C<error_trace>,
    C<human>,
    C<usernames>

See the L<clear_cached_realms docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-clear-cache.html>
for more information.


=head1 USER METHODS

=head2 C<put_user()>

    $response = $es->security->put_user(
        username => $username,     # required
        body     => {...}          # required
    );

The C<put_user()> method creates a new user or updates an existing user.

See the L<User Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_user()>

    $response = $es->security->get_user(
        username => $username | \@usernames     # optional
    );

The C<get_user()> method retrieves info for the specified users (or all users).

See the L<User Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_user()>

    $response = $es->security->delete_user(
        username => $username       # required
    );

The C<delete_user()> method deletes the specified user.

See the L<User Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<change_password()>

    $response = $es->security->change_password(
        username => $username       # optional
        body => {
            password => $password   # required
        }
    )

The C<change_password()> method changes the password for the specified user.

See the L<User Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-users.html>
for more information.

=head2 C<disable_user()>

    $response = $es->security->disable_user(
        username => $username       # required
    );

The C<disable_user()> method disables the specified user.

See the L<User Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<enable_user()>

    $response = $es->security->enable_user(
        username => $username       # required
    );

The C<enable_user()> method enables the specified user.

See the L<User Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head1 ROLE METHODS

=head2 C<put_role()>

    $response = $es->security->put_role(
        name => $name,             # required
        body     => {...}          # required
    );

The C<put_role()> method creates a new role or updates an existing role.

See the L<Role Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_role()>

    $response = $es->security->get_role(
        name => $name | \@names     # optional
    );

The C<get_role()> method retrieves info for the specified roles (or all roles).

See the L<Role Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_role()>

    $response = $es->security->delete_role(
        name => $name       # required
    );

The C<delete_role()> method deletes the specified role.

See the L<Role Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<clear_cached_roles()>

    $response = $es->security->clear_cached_roles(
        names => $names       # required  (comma-separated string)
    );

The C<clear_cached_roles()> method clears the caches for the specified roles.

See the L<Role Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>


=head1 ROLE MAPPING METHODS

=head2 C<put_role_mapping()>

    $response = $es->security->put_role_mapping(
        name => $name,             # required
        body     => {...}          # required
    );

The C<put_role_mapping()> method creates a new role mapping or updates an existing role mapping.

See the L<Role Mapping docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-role-mapping.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_role_mapping()>

    $response = $es->security->get_role_mapping(
        name => $name,             # optional
    );

The C<get_role_mapping()> method retrieves one or more role mappings.

See the L<Role Mapping docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-role-mapping.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_role_mapping()>

    $response = $es->security->delete_role_mapping(
        name => $name,             # required
    );

The C<delete_role_mapping()> method deletes a role mapping.

See the L<Role Mapping docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-role-mapping.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head1 TOKEN METHODS

=head2 C<get_token()>

    $response = $es->security->get_token(
        body     => {...}          # required
    );

The C<get_token()> method enables you to create bearer tokens for access without
requiring basic authentication.

See the L<Token Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-tokens.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<invalidate_token()>

    $response = $es->security->invalidate_token(
        body     => {...}          # required
    );

The C<invalidate_token()> method enables you to invalidate bearer tokens for access without
requiring basic authentication.

See the L<Token Management docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-tokens.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head1 API KEY METHODS

=head2 C<create_api_key()>

    $response = $es->security->create_api_key(
        body    => {...}            # required
    )

The C<create_api_key()> API is used to create API keys which can be used for access instead
of basic authentication.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<refresh>

See the L<Create API Key docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-create-api-key.html> for more.

=head2 C<get_api_key()>

    $response = $es->security->get_api_key(
        id          => $id,         # optional
        name        => $name,       # optional
        realm_name  => $realm,      # optional
        username    => $username    # optional
    )

The C<get_api_key()> API is used to get information about an API key.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<id>,
    C<name>,
    C<realm_name>,
    C<username>

See the L<Get API Key docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-api-key.html> for more.

=head2 C<invalidate_api_key()>

    $response = $es->security->invalidate_api_key(
        id          => $id,         # optional
        name        => $name,       # optional
        realm_name  => $realm,      # optional
        username    => $username    # optional
    )

The C<invalidate_api_key()> API is used to invalidate an API key.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<id>,
    C<name>,
    C<realm_name>,
    C<username>

See the L<Invalidate API Key docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-invalidate-api-key.html> for more.

=head1 USER PRIVILEGE METHODS

=head2 C<get_user_privileges()>

    $response = $es->get_user_privileges();

 The C<get_user_privileges()> method retrieves the privileges granted to the current user.

 Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

=head2 C<has_privileges()>
    $response = $es->has_privileges(
        user    => $user,   # optional
        body    => {...}    # required
    );

 The C<has_privileges()> method checks whether the current or specified user has the listed privileges.

 Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<Has Privileges docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-has-privileges.html> for more.


=head1 APPLICATION PRIVILEGE METHODS

=head2 C<put_privileges()>

    $response = $es->put_privileges(
        application     => $application,    # required
        name            => $name,           # required
        body            => {...}            # required
    );

 The C<put_privileges()> method creates or updates the named privilege for a particular application.

 Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<refresh>

See the L<Create or Update Application Privileges docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-put-privileges.html> for more.

=head2 C<get_privileges()>

    $response = $es->get_privileges(
        application     => $application,    # required
        name            => $name,           # required
    );

 The C<get_privileges()> method retrieves the named privilege for a particular application.

 Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<Get Application Privileges docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-get-privileges.html> for more.

=head2 C<delete_privileges()>

    $response = $es->delete_privileges(
        application     => $application,    # required
        name            => $name,           # required
    );

 The C<delete_privileges()> method deletes the named privilege for a particular application.

 Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<refresh>

See the L<Delete Application Privileges docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-delete-privilege.html> for more.

