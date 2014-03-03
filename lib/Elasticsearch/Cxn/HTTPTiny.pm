package Elasticsearch::Cxn::HTTPTiny;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP',
    'Elasticsearch::Role::Cxn',
    'Elasticsearch::Role::Is_Sync';

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
        $args{content} = $params->{data};
        $args{headers}{'Content-Type'} = $params->{mime_type};
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
        : /$Cxn_Error/               ? 'Cxn'
        :                              'Request';
}

#===================================
sub _build_handle {
#===================================
    my $self = shift;
    my %args = ( keep_alive => 1,default_headers => $self->default_headers );
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

Provides the default HTTP Cxn class and is based on L<HTTP::Tiny>.
The HTTP::Tiny backend is fast, uses pure Perl, support proxies and https
and provides persistent connections.

This class does L<Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information, L<Elasticsearch::Role::Cxn> and
L<Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

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

=item * L<Elasticsearch::Cxn::LWP>

=item * L<Elasticsearch::Cxn::NetCurl>

=back


