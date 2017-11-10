package Search::Elasticsearch::Plugin::XPack::6_0::Security;

use Moo;
with 'Search::Elasticsearch::Plugin::XPack::6_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('xpack.security');

1;

# ABSTRACT: Plugin providing Security API for Search::Elasticsearch 6.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack'],
        userinfo => "username:password"
    );

    my $response = $es->security->authenticate();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<security>
namespace, to support the API for the
L<Security|https://www.elastic.co/products/security> plugin for Elasticsearch.
In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack'],
        userinfo => "username:password"
    );

    my $response = $es->security->authenticate(...);

=head1 METHODS

The full documentation for the Security plugin is available here:
L<https://www.elastic.co/guide/en/x-pack/current/xpack-security.html>

=head2 C<authenticate()>

    $response = $es->security->authenticate()

The C<authenticate()> method checks that the C<userinfo> is correct and returns
a list of which roles are assigned to the user.

See the L<authenticate docs|https://www.elastic.co/guide/en/x-pack/current/security-api-authenticate.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<put_user()>

    $response = $es->security->put_user(
        username => $username,     # required
        body     => {...}          # required
    );

The C<put_user()> method creates a new user or updates an existing user.

See the L<put_user docs|https://www.elastic.co/guide/en/x-pack/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_user()>

    $response = $es->security->get_user(
        username => $username | \@usernames     # optional
    );

The C<get_user()> method retrieves info for the specified users (or all users).

See the L<get_user docs|https://www.elastic.co/guide/en/x-pack/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_user()>

    $response = $es->security->delete_user(
        username => $username       # required
    );

The C<delete_user()> method deletes the specified user.

See the L<delete_user docs|https://www.elastic.co/guide/en/x-pack/current/security-api-users.html>
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

See the L<change_password docs|https://www.elastic.co/guide/en/x-pack/current/security-api-change-password.html>
for more information.


=head2 C<disable_user()>

    $response = $es->security->disable_user(
        username => $username       # required
    );

The C<disable_user()> method disables the specified user.

See the L<disable_user docs|https://www.elastic.co/guide/en/x-pack/current/security-api-users.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<enable_user()>

    $response = $es->security->enable_user(
        username => $username       # required
    );

The C<enable_user()> method enables the specified user.

See the L<enable_user docs|https://www.elastic.co/guide/en/x-pack/current/security-api-users.html>
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

See the L<clear_cached_realms docs|https://www.elastic.co/guide/en/x-pack/current/security-api-clear-cache.html>
for more information.


=head2 C<put_role()>

    $response = $es->security->put_role(
        name => $name,             # required
        body     => {...}          # required
    );

The C<put_role()> method creates a new role or updates an existing role.

See the L<put_role docs|https://www.elastic.co/guide/en/x-pack/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_role()>

    $response = $es->security->get_role(
        name => $name | \@names     # optional
    );

The C<get_role()> method retrieves info for the specified roles (or all roles).

See the L<get_role docs|https://www.elastic.co/guide/en/x-pack/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_role()>

    $response = $es->security->delete_role(
        name => $name       # required
    );

The C<delete_role()> method deletes the specified role.

See the L<delete_role docs|https://www.elastic.co/guide/en/x-pack/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<clear_cached_roles()>

    $response = $es->security->clear_cached_roles(
        names => $names       # required  (comma-separated string)
    );

The C<clear_cached_roles()> method clears the caches for the specified roles.

See the L<clear_cached_roles docs|https://www.elastic.co/guide/en/x-pack/current/security-api-roles.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>



