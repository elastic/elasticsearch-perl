package Elasticsearch::Cxn::LWP;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP',
    'Elasticsearch::Role::Cxn',
    'Elasticsearch::Role::Is_Sync';

use LWP::UserAgent();
use HTTP::Headers();
use HTTP::Request();

my $Cxn_Error = qr/
            Can't.connect
          | Server.closed.connection
          | Connection.refused
            /x;

use namespace::clean;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri    = $self->build_uri($params);
    my $method = $params->{method};

    my $request = HTTP::Request->new(
        $method => $uri,
        [   'Content-Type' => $params->{mime_type},
            %{ $self->default_headers },
        ],
        $params->{data}
    );

    my $ua = $self->handle;
    my $timeout = $params->{timeout} || $self->request_timeout;
    if ( $timeout ne $ua->timeout ) {
        $ua->conn_cache->drop;
        $ua->timeout($timeout);
    }
    my $response = $ua->request($request);

    return $self->process_response(
        $params,               # request
        $response->code,       # code
        $response->message,    # msg
        $response->content,    # body
        $response->headers     # headers
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];

    return
          /read timeout/                           ? 'Timeout'
        : /write failed: Connection reset by peer/ ? 'ContentLength'
        : /$Cxn_Error/                             ? 'Cxn'
        :                                            'Request';
}

#===================================
sub _build_handle {
#===================================
    my $self = shift;
    my %args = (
        keep_alive => 1,
        parse_head => 0
    );
    if ( $self->is_https ) {
        $args{ssl_opts} = { verify_hostname => 0 };
    }
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



