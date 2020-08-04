package Search::Elasticsearch::Client::7_0::Direct::XPack;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('xpack');

1;

__END__

# ABSTRACT: Plugin providing XPack APIs for Search::Elasticsearch v7.x

=head1 SYNOPSIS

    my $response = $es->xpack->info();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<xpack>
namespace.

=head1 METHODS

=head2 C<info()>

    my $response = $es->xpack->info();

Provides general information about the installed X-Pack features.

See the L<info|https://www.elastic.co/guide/en/elasticsearch/reference/current/info-api.html>
for more information.

=head2 C<usage()>

    my $response = $es->xpack->usage();

Provides usage information about the installed X-Pack features.

See the L<usage|https://www.elastic.co/guide/en/elasticsearch/reference/current/usage-api.html>
for more information.