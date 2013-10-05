package Elasticsearch::Cxn::HTTPTiny;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP';

use HTTP::Tiny 0.036 ();
use namespace::clean;

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
        $args{headers}{'Content-Type'} = $params->{mime_type};
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
          /[Tt]imed out/             ? 'Timeout'
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

# ABSTRACT: A Cxn implementation which uses HTTP::Tiny

=head1 DESCRIPTION

Provides an HTTP Cxn class based on L<HTTP::Tiny>.
The HTTP::Tiny backend is fast, uses pure Perl, but doesn't provide
persistent connections. If you are going to use it, make sure you
have a high open filehandle limit (C<ulimit -l>) so that your system
doesn't run out of sockets.

This class does L<Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information.


=head1 SEE ALSO

=over

=item * L<Elasticsearch::Role::Cxn::HTTP>

=item * L<Elasticsearch::Cxn::LWP>

=item * L<Elasticsearch::Cxn::NetCurl>

=back


