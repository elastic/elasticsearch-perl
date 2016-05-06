package Search::Elasticsearch::Cxn::HTTPTiny;

use Moo;
with 'Search::Elasticsearch::Role::Cxn', 'Search::Elasticsearch::Role::Is_Sync';

use HTTP::Tiny 0.043 ();
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
        $args{content}                     = $params->{data};
        $args{headers}{'Content-Type'}     = $params->{mime_type};
        $args{headers}{'Content-Encoding'} = $params->{encoding}
            if $params->{encoding};
    }

    my $handle = $self->handle;
    $handle->timeout( $params->{timeout} || $self->request_timeout );

    my $response = $handle->request( $method, "$uri", \%args );

    return $self->process_response(
        $params,                 # request
        $response->{status},     # code
        $response->{reason},     # msg
        $response->{content},    # body
        $response->{headers}     # headers
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];
    return
          /[Tt]imed out/             ? 'Timeout'
        : /Unexpected end of stream/ ? 'ContentLength'
        : /SSL connection failed/    ? 'SSL'
        : /$Cxn_Error/               ? 'Cxn'
        :                              'Request';
}

#===================================
sub _build_handle {
#===================================
    my $self = shift;
    my %args = ( default_headers => $self->default_headers );
    if ( $self->is_https && $self->has_ssl_options ) {
        $args{SSL_options} = $self->ssl_options;
        if ( $args{SSL_options}{SSL_verify_mode} ) {
            $args{verify_ssl} = 1;
        }
    }

    return HTTP::Tiny->new( %args, %{ $self->handle_args } );
}

1;

# ABSTRACT: A Cxn implementation which uses HTTP::Tiny

=head1 DESCRIPTION

Provides the default HTTP Cxn class and is based on L<HTTP::Tiny>.
The HTTP::Tiny backend is fast, uses pure Perl, support proxies and https
and provides persistent connections.

This class does L<Search::Elasticsearch::Role::Cxn>, whose documentation
provides more information, and L<Search::Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 Inherited configuration

From L<Search::Elasticsearch::Role::Cxn>

=over

=item * L<node|Search::Elasticsearch::Role::Cxn/"node">

=item * L<max_content_length|Search::Elasticsearch::Role::Cxn/"max_content_length">

=item * L<deflate|Search::Elasticsearch::Role::Cxn/"gzip">

=item * L<deflate|Search::Elasticsearch::Role::Cxn/"deflate">

=item * L<request_timeout|Search::Elasticsearch::Role::Cxn/"request_timeout">

=item * L<ping_timeout|Search::Elasticsearch::Role::Cxn/"ping_timeout">

=item * L<dead_timeout|Search::Elasticsearch::Role::Cxn/"dead_timeout">

=item * L<max_dead_timeout|Search::Elasticsearch::Role::Cxn/"max_dead_timeout">

=item * L<sniff_request_timeout|Search::Elasticsearch::Role::Cxn/"sniff_request_timeout">

=item * L<sniff_timeout|Search::Elasticsearch::Role::Cxn/"sniff_timeout">

=item * L<handle_args|Search::Elasticsearch::Role::Cxn/"handle_args">

=item * L<handle_args|Search::Elasticsearch::Role::Cxn/"default_qs_params">

=back

=head1 SSL/TLS

L<Search::Elasticsearch::Cxn::HTTPTiny> uses L<IO::Socket::SSL> to support
HTTPS.  By default, no validation of the remote host is performed.

This behaviour can be changed by passing the C<ssl_options> parameter
with any options accepted by L<IO::Socket::SSL>. For instance, to check
that the remote host has a trusted certificate, and to avoid man-in-the-middle
attacks, you could do the following:

    use Search::Elasticsearch;
    use IO::Socket::SSL;

    my $es = Search::Elasticsearch->new(
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            SSL_verify_mode     => SSL_VERIFY_PEER,
            SSL_ca_file         => '/path/to/cacert.pem'
        }
    );

If the remote server cannot be verified, an
L<Search::Elasticsearch::Error|SSL error> will be thrown.

If you want your client to present its own certificate to the remote
server, then use:

    use Search::Elasticsearch;
    use IO::Socket::SSL;

    my $es = Search::Elasticsearch->new(
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            SSL_verify_mode     => SSL_VERIFY_PEER,
            SSL_use_cert        => 1,
            SSL_ca_file         => '/path/to/cacert.pem',
            SSL_cert_file       => '/path/to/client.pem',
            SSL_key_file        => '/path/to/client.pem',
        }
    );


=head1 METHODS

=head2 C<perform_request()>

    ($status,$body) = $self->perform_request({
        # required
        method      => 'GET|HEAD|POST|PUT|DELETE',
        path        => '/path/of/request',
        qs          => \%query_string_params,

        # optional
        data        => $body_as_string,
        mime_type   => 'application/json',
        timeout     => $timeout
    });

Sends the request to the associated Elasticsearch node and returns
a C<$status> code and the decoded response C<$body>, or throws an
error if the request failed.


=head2 Inherited methods

From L<Search::Elasticsearch::Role::Cxn>

=over

=item * L<scheme()|Search::Elasticsearch::Role::Cxn/"scheme()">

=item * L<is_https()|Search::Elasticsearch::Role::Cxn/"is_https()">

=item * L<userinfo()|Search::Elasticsearch::Role::Cxn/"userinfo()">

=item * L<default_headers()|Search::Elasticsearch::Role::Cxn/"default_headers()">

=item * L<max_content_length()|Search::Elasticsearch::Role::Cxn/"max_content_length()">

=item * L<build_uri()|Search::Elasticsearch::Role::Cxn/"build_uri()">

=item * L<host()|Search::Elasticsearch::Role::Cxn/"host()">

=item * L<port()|Search::Elasticsearch::Role::Cxn/"port()">

=item * L<uri()|Search::Elasticsearch::Role::Cxn/"uri()">

=item * L<is_dead()|Search::Elasticsearch::Role::Cxn/"is_dead()">

=item * L<is_live()|Search::Elasticsearch::Role::Cxn/"is_live()">

=item * L<next_ping()|Search::Elasticsearch::Role::Cxn/"next_ping()">

=item * L<ping_failures()|Search::Elasticsearch::Role::Cxn/"ping_failures()">

=item * L<mark_dead()|Search::Elasticsearch::Role::Cxn/"mark_dead()">

=item * L<mark_live()|Search::Elasticsearch::Role::Cxn/"mark_live()">

=item * L<force_ping()|Search::Elasticsearch::Role::Cxn/"force_ping()">

=item * L<pings_ok()|Search::Elasticsearch::Role::Cxn/"pings_ok()">

=item * L<sniff()|Search::Elasticsearch::Role::Cxn/"sniff()">

=item * L<process_response()|Search::Elasticsearch::Role::Cxn/"process_response()">

=back

=head1 SEE ALSO

=over

=item * L<Search::Elasticsearch::Role::Cxn>

=item * L<Search::Elasticsearch::Cxn::Hijk>

=item * L<Search::Elasticsearch::Cxn::LWP>

=item * L<Search::Elasticsearch::Cxn::NetCurl>

=back


