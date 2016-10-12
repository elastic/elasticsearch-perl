package Search::Elasticsearch::Plugin::XPack::2_0::Shield;

use Moo;
with 'Search::Elasticsearch::Plugin::XPack::2_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('shield');

1;

# ABSTRACT: Plugin providing Shield API for Search::Elasticsearch 2.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack'],
        userinfo => "username:password"
    );

    my $response = $es->shield->authenticate();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<shield>
namespace, to support the API for the
L<Shield|https://www.elastic.co/products/shield> plugin for Elasticsearch.
In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack'],
        userinfo => "username:password"
    );

    my $response = $es->shield->authenticate();

=head1 METHODS

The full documentation for the Shield plugin is available here:
L<http://www.elastic.co/guide/en/shield/current/>

=head2 C<authenticate()>

    $response = $es->shield->authenticate()

The C<authenticate()> method checks that the C<userinfo> is correct and returns
a list of which roles are assigned to the user.

See the L<authenticate docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-authenticate-rest>
for more information.


=head2 C<put_user()>

    $response = $es->shield->put_user(
        username => $username,     # required
        body     => {...}          # required
    );

The C<put_user()> method creates a new user or updates an existing user.

See the L<put_user docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-users-rest>
for more information.

=head2 C<get_user()>

    $response = $es->shield->get_user(
        username => $username | \@usernames     # optional
    );

The C<get_user()> method retrieves info for the specified users (or all users).

See the L<get_user docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-users-rest>
for more information.

=head2 C<delete_user()>

    $response = $es->shield->delete_user(
        username => $username       # required
    );

The C<delete_user()> method deletes the specified user.

See the L<delete_user docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-users-rest>
for more information.

=head2 C<clear_cached_realms()>

    $response = $es->shield->clear_cached_realms(
        realms => $realms       # required  (comma-separated string)
    );

The C<clear_cached_realms()> method clears the caches for the specified realms

Query string parameters:
    C<usernames>

See the L<clear_cached_realms docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-clear-cache-rest>
for more information.


=head2 C<put_role()>

    $response = $es->shield->put_role(
        name => $name,             # required
        body     => {...}          # required
    );

The C<put_role()> method creates a new role or updates an existing role.

See the L<put_role docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-roles-rest>
for more information.

=head2 C<get_role()>

    $response = $es->shield->get_role(
        name => $name | \@names     # optional
    );

The C<get_role()> method retrieves info for the specified roles (or all roles).

See the L<get_role docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-roles-rest>
for more information.

=head2 C<delete_role()>

    $response = $es->shield->delete_role(
        name => $name       # required
    );

The C<delete_role()> method deletes the specified role.

See the L<delete_role docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-roles-rest>
for more information.

=head2 C<clear_cached_roles()>

    $response = $es->shield->clear_cached_roles(
        names => $names       # required  (comma-separated string)
    );

The C<clear_cached_roles()> method clears the caches for the specified roles.

See the L<clear_cached_roles docs|http://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-clear-cache-rest>
for more information.



