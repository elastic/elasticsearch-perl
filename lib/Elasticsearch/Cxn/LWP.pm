package Elasticsearch::Cxn::LWP;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP';

use LWP::UserAgent();
use HTTP::Headers();
use HTTP::Request();

use namespace::clean;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri    = $self->build_uri($params);
    my $method = $params->{method};

    my $request = HTTP::Request->new(
        $method => $uri,
        [   'Content-Type' => $params->{mime_type}
                || $self->serializer->mime_type
        ],
        $params->{data}
    );

    my $ua = $self->handle;
    $ua->timeout( $params->{timeout} || $self->request_timeout );
    my $response = $ua->request($request);

    return $self->process_response(
        $params,                                 # request
        $response->code,                         # code
        $response->message,                      # msg
        $response->content,                      # body
        $response->header('content-encoding')    # encoding,
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];

    return
          /read timeout/                           ? 'Timeout'
        : /write failed: Connection reset by peer/ ? 'ContentLength'
        : /Can't connect|Server closed connection/ ? 'Cxn'
        :                                            'Request';
}

#===================================
sub _build_handle {
#===================================
    my $self = shift;
    my %args = (
        verify_hostname => 0,
        default_headers => HTTP::Headers->new( $self->default_headers ),
        keep_alive      => 1,
        parse_head      => 0
    );

    return LWP::UserAgent->new( %args, %{ $self->handle_args } );
}

1;

# ABSTRACT: A Cxn implementation which uses LWP

=head1 DESCRIPTION

Provides the default HTTP Cxn class and is based on L<LWP>.
The LWP backend uses pure Perl and persistent connections.

This class does L<Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information.

=head1 SEE ALSO

=over

=item * L<Elasticsearch::Role::Cxn::HTTP>

=item * L<Elasticsearch::Cxn::HTTPTiny>

=item * L<Elasticsearch::Cxn::NetCurl>

=back



