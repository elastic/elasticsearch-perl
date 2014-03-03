package Elasticsearch::Cxn::Hijk;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP',
    'Elasticsearch::Role::Cxn',
    'Elasticsearch::Role::Is_Sync';

use Hijk 0.12;
use Try::Tiny;
use namespace::clean;

has 'connect_timeout' => ( is => 'ro', default => 2 );
has '_socket_cache' => ( is => 'ro', default => sub { {} } );

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
        query_string    => $uri->query,
    );
    if ( defined $params->{data} ) {
        $args{body} = $params->{data};
        $args{head} = [ 'Content-Type', $params->{mime_type} ];
    }

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
        $params,                # request
        $response->{status},    # code
        $response->{error},     # msg
        $response->{body},      # body
        \%head                  # headers
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];

    no warnings 'numeric';
    my $type
        = 0 + $_ & Hijk::Error::TIMEOUT        ? 'Timeout'
        : 0 + $_ & Hijk::Error::CANNOT_RESOLVE ? 'Cxn'
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
L<Elasticsearch::Cxn::NetCurl>, but doesn't provide support for
https or proxies.

This class does L<Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information, L<Elasticsearch::Role::Cxn> and
L<Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 C<connect_timeout>

Unlike most HTTP backends, L<Hijk> accepts a separate C<connect_timeout>
parameter, which defaults to C<2> seconds but can be reduced in an
environment with low network latency.

=head2 Inherited configuration

From L<Elasticsearch::Role::Cxn::HTTP>

=over

=item * L<node|Elasticsearch::Role::Cxn::HTTP/"node">

=item * L<max_content_length|Elasticsearch::Role::Cxn::HTTP/"max_content_length">

=item * L<deflate|Elasticsearch::Role::Cxn::HTTP/"deflate">

=back

From L<Elasticsearch::Role::Cxn>

=over

=item * L<request_timeout|Elasticsearch::Role::Cxn/"request_timeout">

=item * L<ping_timeout|Elasticsearch::Role::Cxn/"ping_timeout">

=item * L<dead_timeout|Elasticsearch::Role::Cxn/"dead_timeout">

=item * L<max_dead_timeout|Elasticsearch::Role::Cxn/"max_dead_timeout">

=item * L<sniff_request_timeout|Elasticsearch::Role::Cxn/"sniff_request_timeout">

=item * L<sniff_timeout|Elasticsearch::Role::Cxn/"sniff_timeout">

=item * L<handle_args|Elasticsearch::Role::Cxn/"handle_args">

=back

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

From L<Elasticsearch::Role::Cxn::HTTP>

=over

=item * L<scheme()|Elasticsearch::Role::Cxn::HTTP/"scheme()">

=item * L<is_https()|Elasticsearch::Role::Cxn::HTTP/"is_https()">

=item * L<userinfo()|Elasticsearch::Role::Cxn::HTTP/"userinfo()">

=item * L<default_headers()|Elasticsearch::Role::Cxn::HTTP/"default_headers()">

=item * L<max_content_length()|Elasticsearch::Role::Cxn::HTTP/"max_content_length()">

=item * L<build_uri()|Elasticsearch::Role::Cxn::HTTP/"build_uri()">

=back

From L<Elasticsearch::Role::Cxn>

=over

=item * L<host()|Elasticsearch::Role::Cxn/"host()">

=item * L<port()|Elasticsearch::Role::Cxn/"port()">

=item * L<uri()|Elasticsearch::Role::Cxn/"uri()">

=item * L<is_dead()|Elasticsearch::Role::Cxn/"is_dead()">

=item * L<is_live()|Elasticsearch::Role::Cxn/"is_live()">

=item * L<next_ping()|Elasticsearch::Role::Cxn/"next_ping()">

=item * L<ping_failures()|Elasticsearch::Role::Cxn/"ping_failures()">

=item * L<mark_dead()|Elasticsearch::Role::Cxn/"mark_dead()">

=item * L<mark_live()|Elasticsearch::Role::Cxn/"mark_live()">

=item * L<force_ping()|Elasticsearch::Role::Cxn/"force_ping()">

=item * L<pings_ok()|Elasticsearch::Role::Cxn/"pings_ok()">

=item * L<sniff()|Elasticsearch::Role::Cxn/"sniff()">

=item * L<process_response()|Elasticsearch::Role::Cxn/"process_response()">

=back

=head1 SEE ALSO

=over

=item * L<Elasticsearch::Role::Cxn::HTTP>

=item * L<Elasticsearch::Cxn::HTTPTiny>

=item * L<Elasticsearch::Cxn::LWP>

=item * L<Elasticsearch::Cxn::NetCurl>

=back


