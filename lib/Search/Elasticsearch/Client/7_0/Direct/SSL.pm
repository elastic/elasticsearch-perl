package Search::Elasticsearch::Client::7_0::Direct::SSL;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('ssl');

1;

__END__

# ABSTRACT: Plugin providing SSL for Search::Elasticsearch 7.x

=head1 SYNOPSIS

    my $response = $es->ssl->certificates()

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<ssl>
namespace, to support the
L<SSL APIs|https://www.elastic.co/guide/en/elasticsearch/reference/current/security-api-ssl.html>.

=head1 GENERAL METHODS

=head2 C<certificates()>

    $response = $es->ssl->certificates()

The C<certificates()> method returns all the certificate information on a single node of Elasticsearch.
