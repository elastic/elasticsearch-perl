package Search::Elasticsearch::Serializer::JSON::XS;

use Moo;
use JSON::XS;

has 'JSON' => ( is => 'ro', default => sub { JSON::XS->new->utf8(1) } );

with 'Search::Elasticsearch::Role::Serializer::JSON';

1;

__END__

# ABSTRACT: A JSON Serializer using JSON::XS

=head1 SYNOPSIS

    $e = Search::Elasticsearch(
        serializer => 'JSON::XS'
    );

=head1 DESCRIPTION

While the default serializer, L<Search::Elasticsearch::Serializer::JSON>,
tries to choose the appropriate JSON backend, this module allows you to
choose the L<JSON::XS> backend specifically.

This class does L<Search::Elasticsearch::Role::Serializer::JSON>.

=head1 SEE ALSO

=over

=item * L<Search::Elasticsearch::Serializer::JSON>

=item * L<Search::Elasticsearch::Serializer::JSON::Cpanel>

=item * L<Search::Elasticsearch::Serializer::JSON::PP>

=back
