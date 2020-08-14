# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

package Search::Elasticsearch::Cxn::AEHTTP;

use AnyEvent::HTTP qw(http_request);
use Promises qw(deferred);
use Try::Tiny;
use Moo;

with 'Search::Elasticsearch::Role::Cxn::Async';
with 'Search::Elasticsearch::Role::Cxn',
    'Search::Elasticsearch::Role::Is_Async';

has '_tls_ctx' => ( is => 'lazy' );

use namespace::clean;

#===================================
sub _build__tls_ctx {
#===================================
    my $self = shift;
    return 'low' unless $self->has_ssl_options;
    require AnyEvent::TLS;
    return AnyEvent::TLS->new( %{ $self->ssl_options } );
}

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri     = $self->build_uri($params);
    my $method  = $params->{method};
    my %headers = ( %{ $self->default_headers } );
    my $data    = $params->{data};
    if ( defined $data ) {
        $headers{'Content-Type'}     = $params->{mime_type};
        $headers{'Content-Encoding'} = $params->{encoding}
            if $params->{encoding};
    }

    my $deferred = deferred;

    http_request(
        $method => $uri,
        headers => \%headers,
        timeout => $params->{timeout} || $self->request_timeout,
        body => $data,
        persistent => 0,
        session    => $self->_pid,
        ( %{ $self->handle_args } ),
        ( $self->is_https ? ( tls_ctx => $self->_tls_ctx ) : () ),
        sub {
            my ( $body, $headers ) = @_;
            try {
                my ( $code, $response ) = $self->process_response(
                    $params,                      # request
                    delete $headers->{Status},    # code
                    delete $headers->{Reason},    # msg
                    $body,                        # body
                    $headers                      # headers
                );
                $deferred->resolve( $code, $response );
            }
            catch {
                $deferred->reject($_);
            }

        }
    );
    $deferred->promise;
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];
    return
          /[Tt]imed out/              ? 'Timeout'
        : /certificate verify failed/ ? 'SSL'
        : /Invalid argument/          ? 'Cxn'
        :                               'Request';
}

1;

# ABSTRACT: An async Cxn implementation which uses AnyEvent::HTTP

=head1 DESCRIPTION

Provides the default async HTTP Cxn class and is based on L<AnyEvent::HTTP>.
The AEHTTP backend is fast, uses pure Perl, support proxies and https
and provides persistent connections.

This class does L<Search::Elasticsearch::Role::Cxn>, whose documentation
provides more information, L<Search::Elasticsearch::Role::Async::Cxn>,
and L<Search::Elasticsearch::Role::Is_Async>.

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

L<Search::Elasticsearch::Cxn::AEHTTP> uses L<AnyEvent::TLS> to support
HTTPS.  By default, no validation of the remote host is performed.

This behaviour can be changed by passing the C<ssl_options> parameter
with any options accepted by L<AnyEvent::TLS>. For instance, to check
that the remote host has a trusted certificate, and to avoid man-in-the-middle
attacks, you could do the following:

    use Search::Elasticsearch::Async;

    my $es = Search::Elasticsearch::Async->new(
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            verify              => 1,
            verify_peername     => 'https'
            ca_file             => '/path/to/cacert.pem'
        }
    );

If the remote server cannot be verified, an
L<Search::Elasticsearch::Error|SSL error> will be thrown.

If you want your client to present its own certificate to the remote
server, then use:

    use Search::Elasticsearch::Async;

    my $es = Search::Elasticsearch::Async->new(
        nodes => [
            "https://node1.mydomain.com:9200",
            "https://node2.mydomain.com:9200",
        ],
        ssl_options => {
            verify              => 1,
            verify_peername     => 'https'
            ca_file             => '/path/to/cacert.pem'
            cert_file           => '/path/to/client.pem',
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

From L<Search::Elasticsearch::Role::Async::Cxn>

=over

=item * L<pings_ok()|Search::Elasticsearch::Role::Async::Cxn/"pings_ok()">

=item * L<sniff()|Search::Elasticsearch::Role::Async::Cxn/"sniff()">

=back


=head1 SEE ALSO

=over

=item * L<Search::Elasticsearch::Role::Cxn::Mojo>

=back


