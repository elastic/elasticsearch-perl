package Elasticsearch::Cxn::HTTPTiny;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP';

use namespace::autoclean;
use HTTP::Tiny v0.33 ();

my $Cxn_Error = qr/ Connection.(?:timed.out|re(?:set|fused))
                       | connect:.timeout
                       | Host.is.down
                       | No.route.to.host
                       | temporarily.unavailable
                       /x;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri    = $self->build_uri($params);
    my $method = $params->{method};

    my %args;
    if ( defined $params->{data} ) {
        $args{content} = $params->{data};
        $args{headers}{'Content-Type'}
            = $params->{mime_type} || $self->serializer->mime_type;
    }

    my $handle = $self->handle;
    $handle->timeout( $params->{timeout} || $self->request_timeout );

    my $response = $handle->request( $method, "$uri", \%args );

    return $self->process_response(
        $params,                                    # request
        $response->{status},                        # code
        $response->{reason},                        # msg
        $response->{content},                       # body
        $response->{headers}{'content-encoding'}    # encoding,
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];
    return
          /Timed out/                ? 'Timeout'
        : /Unexpected end of stream/ ? 'ContentLength'
        : /$Cxn_Error/               ? 'Cxn'
        :                              'Request';
}

#===================================
sub _build_handle {
#===================================
    my $self = shift;
    my %args = ( default_headers => $self->default_headers );
    if ( $self->is_https ) {
        require IO::Socket::SSL;
        $args{SSL_options}{SSL_verify_mode}
            = IO::Socket::SSL::SSL_VERIFY_NONE();
    }

    return HTTP::Tiny->new( %args, %{ $self->handle_args } );
}

1;
