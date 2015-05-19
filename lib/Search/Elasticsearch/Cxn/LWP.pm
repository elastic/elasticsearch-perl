package Search::Elasticsearch::Cxn::LWP;

use Moo;
with 'Search::Elasticsearch::Role::Cxn::HTTP',
    'Search::Elasticsearch::Role::Cxn',
    'Search::Elasticsearch::Role::Is_Sync';

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
        $args{ssl_opts}
            = $self->has_ssl_options
            ? $self->ssl_options
            : { verify_hostname => 0 };
    }
    return LWP::UserAgent->new( %args, %{ $self->handle_args } );
}

1;

# ABSTRACT: A Cxn implementation which uses LWP

=head1 DESCRIPTION

Provides an HTTP Cxn class and based on L<LWP>.
The LWP backend uses pure Perl and persistent connections.

This class does L<Search::Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information, L<Search::Elasticsearch::Role::Cxn> and
L<Search::Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 Inherited configuration

From L<Search::Elasticsearch::Role::Cxn::HTTP>

=over

=item * L<node|Search::Elasticsearch::Role::Cxn::HTTP/"node">

=item * L<max_content_length|Search::Elasticsearch::Role::Cxn::HTTP/"max_content_length">

=item * L<deflate|Search::Elasticsearch::Role::Cxn::HTTP/"deflate">

=back

From L<Search::Elasticsearch::Role::Cxn>

=over

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

L<Search::Elasticsearch::Cxn::LWP> uses L<IO::Socket::SSL> to support
HTTPS.  By default, no validation of the remote host is performed.

This behaviour can be changed by passing the C<ssl_options> parameter
with any options accepted by L<IO::Socket::SSL>. For instance, to check
that the remote host has a trusted certificate, and to avoid man-in-the-middle
attacks, you could do the following:

    use Search::Elasticsearch;

    my $es = Search::Elasticsearch->new(
        cxn   => 'LWP',
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            verify_hostname     => 1,
            SSL_ca_file         => '/path/to/cacert.pem'
        }
    );

If the remote server cannot be verified, an
L<Search::Elasticsearch::Error|Cxn error> will be thrown - LWP does not
allow us to detect that the connection error was due to invalid SSL.

If you want your client to present its own certificate to the remote
server, then use:

    use Search::Elasticsearch;

    my $es = Search::Elasticsearch->new(
        cxn   => 'LWP',
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            verify_hostname     => 1,
            SSL_ca_file         => '/path/to/cacert.pem',
            SSL_use_cert        => 1,
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

From L<Search::Elasticsearch::Role::Cxn::HTTP>

=over

=item * L<scheme()|Search::Elasticsearch::Role::Cxn::HTTP/"scheme()">

=item * L<is_https()|Search::Elasticsearch::Role::Cxn::HTTP/"is_https()">

=item * L<userinfo()|Search::Elasticsearch::Role::Cxn::HTTP/"userinfo()">

=item * L<default_headers()|Search::Elasticsearch::Role::Cxn::HTTP/"default_headers()">

=item * L<max_content_length()|Search::Elasticsearch::Role::Cxn::HTTP/"max_content_length()">

=item * L<build_uri()|Search::Elasticsearch::Role::Cxn::HTTP/"build_uri()">

=back

From L<Search::Elasticsearch::Role::Cxn>

=over

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

=item * L<Search::Elasticsearch::Role::Cxn::HTTP>

=item * L<Search::Elasticsearch::Cxn::HTTPTiny>

=item * L<Search::Elasticsearch::Cxn::Hijk>

=item * L<Search::Elasticsearch::Cxn::NetCurl>

=back



