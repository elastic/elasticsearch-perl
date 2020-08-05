# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Serializer::JSON::Cpanel;

use Cpanel::JSON::XS;
use Moo;

has 'JSON' =>
    ( is => 'ro', default => sub { Cpanel::JSON::XS->new->utf8(1) } );

with 'Search::Elasticsearch::Role::Serializer::JSON';

1;

__END__

# ABSTRACT: A JSON Serializer using Cpanel::JSON::XS

=head1 SYNOPSIS

    $e = Search::Elasticsearch(
        serializer => 'JSON::Cpanel'
    );

=head1 DESCRIPTION

While the default serializer, L<Search::Elasticsearch::Serializer::JSON>,
tries to choose the appropriate JSON backend, this module allows you to
choose the L<Cpanel::JSON::XS> backend specifically.

This class does L<Search::Elasticsearch::Role::Serializer::JSON>.

=head1 SEE ALSO

=over

=item * L<Search::Elasticsearch::Serializer::JSON>

=item * L<Search::Elasticsearch::Serializer::JSON::XS>

=item * L<Search::Elasticsearch::Serializer::JSON::PP>

=back
