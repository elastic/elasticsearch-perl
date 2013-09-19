package Elasticsearch::MockCxn;

use Data::Dumper;
use Moo;
with 'Elasticsearch::Role::Cxn::HTTP';

has 'mock_responses' => ( is => 'rw', required => 1 );
has 'marked_live' => ( is => 'rw', default => sub {0} );

#===================================
sub error_from_text { return $_[2] }
#===================================

#===================================
sub perform_request {
#===================================
    my $self = shift;

    my $params   = shift;
    my $response = shift @{ $self->mock_responses }
        or die "Mock responses exhausted";

    if ( $response->{code} ) {

        $self->logger->debug( '['
                . $self->host
                . '] REQUEST: '
                . ( $response->{error} || $response->{code} ) );
    }
    else {
        $self->logger->debug( '['
                . $self->host
                . '] PING: '
                . ( $response->{ping} ? 'OK' : 'NOT_OK' ) );
        $response
            = $response->{ping}
            ? { code => 200 }
            : { code => 500, error => 'Cxn' };
    }

    return $self->process_response(
        $params,                 # request
        $response->{code},       # code
        $response->{error},      # msg
        $response->{content},    # body
    );
}

1
