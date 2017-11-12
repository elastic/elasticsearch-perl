package Search::Elasticsearch::Plugin::XPack::6_0::License;

use Moo;
with 'Search::Elasticsearch::Plugin::XPack::6_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('xpack.license');

1;

# ABSTRACT: Plugin providing License API for Search::Elasticsearch 6.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack']
    );

    my $response = $es->xpack->license->get();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<license>
namespace, to support the API for the License plugin for Elasticsearch.
In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack']
    );

    my $response = $es->xpack->license->get();

=head1 METHODS

The full documentation for the License plugin is available here:
L<https://www.elastic.co/guide/en/x-pack/current/license-management.html>

=head2 C<get()>

    $response = $es->xpack->license->get()

The C<get()> method returns the currently installed license.

See the L<license.get docs|https://www.elastic.co/guide/en/x-pack/current/listing-licenses.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<local>

=head2 C<post()>

    $response = $es->xpack->license->post(
        body     => {...}          # required
    );

The C<post()> method adds or updates the license for the cluster. The C<body>
can be passed as JSON or as a string.

See the L<license.put docs|https://www.elastic.co/guide/en/x-pack/current/installing-license.html>
for more information.

Query string parameters:
    C<acknowledge>,
    C<error_trace>,
    C<human>
