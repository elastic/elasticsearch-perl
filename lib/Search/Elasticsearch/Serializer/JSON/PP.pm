package Search::Elasticsearch::Serializer::JSON::PP;

use Moo;
use JSON::PP;

has 'JSON' => ( is => 'ro', default => sub { JSON::PP->new->utf8(1) } );

with 'Search::Elasticsearch::Role::Serializer::JSON';

1;

# ABSTRACT: A JSON Serializer using JSON::PP

=head1 SYNOPSIS

    $e = Search::Elasticsearch(
        serializer => 'JSON::PP'
    );

=head1 DESCRIPTION

While the default serializer, L<Search::Elasticsearch::Serializer::JSON>,
tries to choose the appropriate JSON backend, this module allows you to
choose the L<JSON::PP> backend specifically.

B<NOTE:> You should really install and use either L<JSON::XS> or
L<Cpanel::JSON::XS> as they are much much faster than L<JSON::PP>.

This class does L<Search::Elasticsearch::Role::Serializer::JSON>.

=head1 SEE ALSO

=over

=item * L<Search::Elasticsearch::Serializer::JSON>

=item * L<Search::Elasticsearch::Serializer::JSON::XS>

=item * L<Search::Elasticsearch::Serializer::JSON::Cpanel>

=back
