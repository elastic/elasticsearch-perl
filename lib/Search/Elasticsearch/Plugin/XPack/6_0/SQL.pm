package Search::Elasticsearch::Plugin::XPack::6_0::SQL;

use Moo;
with 'Search::Elasticsearch::Plugin::XPack::6_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('xpack.sql');

1;

# ABSTRACT: Plugin providing SQL for Search::Elasticsearch 6.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack']
    );

    my $response = $es->xpack->sql->query( body => {...} )

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<sql>
namespace, to support the
L<SQL APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-rest.html>.

The full documentation for the SQL feature is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/xpack-sql.html>

=head1 GENERAL METHODS

=head2 C<query()>

    $response = $es->xpack->sql->query(
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

    $response = $es->xpack->sql->translate(
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

    $response = $es->xpack->sql->clear_cursor(
        body    => {...} # required
    )

The C<clear_cursor()> method cleans up an ongoing scroll request.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<query docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/sql-rest.html>
for more information.

