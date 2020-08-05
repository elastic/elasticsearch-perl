# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Role::Client;

use Moo::Role;
use namespace::clean;

requires 'parse_request';

has 'transport' => ( is => 'ro', required => 1 );
has 'logger'    => ( is => 'ro', required => 1 );

#===================================
sub perform_request {
#===================================
    my $self    = shift;
    my $request = $self->parse_request(@_);
    return $self->transport->perform_request($request);
}

1;

__END__

# ABSTRACT: Provides common functionality for Client implementations

=head1 DESCRIPTION

This role provides a common C<perform_request()> method for Client
implementations.

=head1 METHODS

=head2 C<perform_request()>

This method takes whatever arguments it is passed and passes them directly to
a C<parse_request()> method (which should be provided by Client implementations).
The C<parse_request()> method should return a request suitable for passing
to L<Search::Elasticsearch::Transport/perform_request()>.
