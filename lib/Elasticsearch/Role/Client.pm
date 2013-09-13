package Elasticsearch::Role::Client;

use Moo::Role;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

requires 'parse_request','api';

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
