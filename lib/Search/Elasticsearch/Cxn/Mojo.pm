package Search::Elasticsearch::Cxn::Mojo;

use Mojo::UserAgent();
use Promises qw(deferred);
use Try::Tiny;
use Moo;

with 'Search::Elasticsearch::Role::Cxn::Async';
with 'Search::Elasticsearch::Role::Cxn::HTTP',
    'Search::Elasticsearch::Role::Cxn',
    'Search::Elasticsearch::Role::Is_Async';

has 'connect_timeout' => ( is => 'ro', default => 2 );

use namespace::clean;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;

    my $uri     = $self->build_uri($params) . '';
    my $method  = $params->{method};
    my %headers = ( %{ $self->default_headers } );

    my @args = ( $method, $uri, \%headers );
    my $data = $params->{data};
    if ( defined $data ) {
        $headers{'Content-Type'} = $params->{mime_type};
        push @args, $data;
    }

    my $handle = $self->handle;
    $handle->connect_timeout( $self->connect_timeout );
    $handle->request_timeout( $params->{timeout} || $self->request_timeout );

    my $tx = $handle->build_tx(@args);

    my $deferred = deferred;
    $tx = $handle->start(
        $tx,
        sub {
            my ( $ua, $tx ) = @_;
            my $res = $tx->res;
            my $error;
            if ( $error = $res->error ) {
                $error = $error->{message}
                    if ref $error eq 'HASH';
            }

            my $headers = $res->headers->to_hash;
            $headers->{ lc($_) } = delete $headers->{$_} for keys %{$headers};
            try {
                my ( $code, $response ) = $self->process_response(
                    $params,    # request
                    ( $res->code || 500 ),    # status
                    $error,                   # reason
                    $res->body,               # content
                    $headers,                 # headers
                );
                $deferred->resolve( $code, $response );
            }
            catch {
                $deferred->reject($_);
            };
        }
    );
    $deferred->promise;
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];
    return
          /[Tt]imed out/     ? 'Timeout'
        : /Invalid argument/ ? 'Cxn'
        :                      'Request';
}

#===================================
sub _build_handle {
#===================================
    my $self = shift;
    my %args = %{ $self->handle_args };
    if ( $self->is_https && $self->has_ssl_options ) {
        %args = ( %args, %{ $self->ssl_options } );
    }
    return Mojo::UserAgent->new(%args);
}
1;

# ABSTRACT: An async Cxn implementation which uses Mojo::UserAgent

=head1 DESCRIPTION

Provides an async HTTP Cxn class based on L<Mojo::UserAgent>.
The Mojo backend is fast, uses pure Perl, support proxies and https
and provides persistent connections.

This class does L<Search::Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information, L<Search::Elasticsearch::Role::Async::Cxn>,
L<Search::Elasticsearch::Role::Cxn> and L<Search::Elasticsearch::Role::Is_Async>.

=head1 CONFIGURATION

=head2 C<connect_timeout>

Unlike most HTTP backends, L<Mojo::UserAgent> accepts a separate C<connect_timeout>
parameter, which defaults to C<2> seconds but can be reduced in an
environment with low network latency.

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

=back

=head1 SSL/TLS

L<Search::Elasticsearch::Cxn::Mojo> does no validation of the remote host by default.

This behaviour can be changed by passing the C<ssl_options> parameter
with the C<ca>, C<cert>, and C<key> options. For instance, to check
that the remote host has a trusted certificate, and to avoid man-in-the-middle
attacks, you could do the following:

    use Search::Elasticsearch::Async;

    my $es = Search::Elasticsearch::Async->new(
        cxn   => 'Mojo',
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            ca  => '/path/to/cacert.pem'
        }
    );

If you want your client to present its own certificate to the remote
server, then use:

    use Search::Elasticsearch::Async;

    my $es = Search::Elasticsearch::Async->new(
        cxn   => 'Mojo',
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            ca   => '/path/to/cacert.pem'
            cert => '/path/to/client.pem',
            key  => '/path/to/client.pem'
        }
    );


=head1 METHODS

=head2 C<perform_request()>

    $self->perform_request({
        # required
        method      => 'GET|HEAD|POST|PUT|DELETE',
        path        => '/path/of/request',
        qs          => \%query_string_params,

        # optional
        data        => $body_as_string,
        mime_type   => 'application/json',
        timeout     => $timeout
    })
    ->then(sub { my ($status,body) = @_; ...})

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

From L<Search::Elasticsearch::Role::Async::Cxn>

=over

=item * L<pings_ok()|Search::Elasticsearch::Role::Cxn/"pings_ok()">

=item * L<sniff()|Search::Elasticsearch::Role::Cxn/"sniff()">

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

=item * L<Search::Elasticsearch::Role::Cxn::AEHTTP>

=back
