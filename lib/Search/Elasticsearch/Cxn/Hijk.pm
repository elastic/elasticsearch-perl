package Search::Elasticsearch::Cxn::Hijk;

use Moo;
with 'Search::Elasticsearch::Role::Cxn', 'Search::Elasticsearch::Role::Is_Sync';

use Hijk 0.27;
use Try::Tiny;
use namespace::clean;

has 'connect_timeout' => ( is => 'ro', default => 2 );
has '_socket_cache' => ( is => 'rw', default => sub { {} } );

my $Cxn_Error = qr/ Connection.(?:timed.out|re(?:set|fused))
                       | connect:.timeout
                       | Host.is.down
                       | No.route.to.host
                       | temporarily.unavailable
                       | Socket.is.not.connected
                       | Broken.pipe
                       | Failed.to
                       | select\(2\)
                       | connect\(2\)
                       | send.error
                       | zombie.error
                       /x;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri    = $self->build_uri($params);
    my $method = $params->{method};
    my $cache  = $self->_socket_cache;

    my %args = (
        host            => $uri->host,
        port            => $uri->port,
        socket_cache    => $self->_socket_cache,
        connect_timeout => $self->request_timeout,
        read_timeout    => $params->{timeout} || $self->request_timeout,
        method          => $method,
        path            => $uri->path,
        %{ $self->handle_args }
    );

    my $headers = {};
    if ( defined $params->{data} ) {
        $args{body} = $params->{data};
        $headers->{'Content-Type'} = $params->{mime_type};
        $headers->{'Content-Encoding'} = $params->{encoding}
            if $params->{encoding};
    }

    ($uri, $headers) = $self->cxn_auth->authenticate_request( $method, $uri, $headers, $params->{data} );

    push @{ $args{head} }, %$headers, %{ $self->default_headers };

    $args{query_string} = $uri->query;

    my $response;
    try {
        local $SIG{PIPE} = sub { die $! };
        $response = Hijk::request( \%args );
    }
    catch {
        $response = {
            status => 500,
            error  => $_ || 'Unknown error'
        };
    };

    my $head = $response->{head} || {};
    my %head = map { lc($_) => $head->{$_} } keys %$head;

    return $self->process_response(
        $params,    # request
        $response->{status} || 500,    # code
        $response->{error},            # msg
        $response->{body}
            || $response->{error_message}
            || $response->{errno_string},    # body
        \%head                               # headers
    );
}

#===================================
sub clear_handle {
#===================================
    my $self = shift;
    $self->_socket_cache( {} );
}
#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];

    no warnings 'numeric';
    my $type
        = 0 + $_ & Hijk::Error::TIMEOUT        ? 'Timeout'
        : 0 + $_ & Hijk::Error::CANNOT_RESOLVE ? 'Cxn'
        : 0 + $_ & Hijk::Error::REQUEST_ERROR  ? 'Cxn'
        : 0 + $_ & Hijk::Error::RESPONSE_ERROR ? 'Cxn'
        : /Connection reset by peer/           ? 'ContentLength'
        : m/$Cxn_Error/                        ? 'Cxn'
        :                                        'Request';

    if ( $type eq 'Cxn' || $type eq 'Timeout' ) {
        %{ $_[0]->_socket_cache } = ();
    }
    return $type;
}

1;

# ABSTRACT: A Cxn implementation which uses Hijk

=head1 DESCRIPTION

Provides an HTTP Cxn class based on L<Hijk>.
The Hijk backend is pure Perl and is very fast, faster even that
L<Search::Elasticsearch::Cxn::NetCurl>, but doesn't provide support for
https or proxies.

This class does L<Search::Elasticsearch::Role::Cxn>, whose documentation
provides more information, and L<Search::Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 C<connect_timeout>

Unlike most HTTP backends, L<Hijk> accepts a separate C<connect_timeout>
parameter, which defaults to C<2> seconds but can be reduced in an
environment with low network latency.

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

L<Search::Elasticsearch::Cxn::Hijk> does not support HTTPS.

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

=item * L<Search::Elasticsearch::Cxn::HTTPTiny>

=item * L<Search::Elasticsearch::Cxn::LWP>

=item * L<Search::Elasticsearch::Cxn::NetCurl>

=back


