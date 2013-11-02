package Elasticsearch::Role::Serializer;

use Moo::Role;

requires qw(encode decode encode_pretty encode_bulk mime_type);

1;

# ABSTRACT: An interface for Serializer modules

=head1 DESCRIPTION

There is no code in this module. It defines an interface for
Serializer implementations, and requires the following methods:

=over

=item *

C<encode()>

=item *

C<encode_pretty()>

=item *

C<encode_bulk()>

=item *

C<decode()>

=item *

C<mime_type()>

=back


See L<Elasticsearch::Serializer::JSON> for more.
