package Elasticsearch::Cxn::NetCurl;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP',
    'Elasticsearch::Role::Cxn',
    'Elasticsearch::Role::Is_Sync';

use Elasticsearch 1.05;
our $VERSION = "1.05";

use HTTP::Parser::XS qw(HEADERS_AS_HASHREF parse_http_response);
use Try::Tiny;
use Net::Curl::Easy qw(
    CURLOPT_HEADER
    CURLOPT_VERBOSE
    CURLOPT_URL
    CURLOPT_CONNECTTIMEOUT_MS
    CURLOPT_CUSTOMREQUEST
    CURLOPT_TIMEOUT_MS
    CURLOPT_POSTFIELDS
    CURLOPT_POSTFIELDSIZE
    CURLOPT_HTTPHEADER
    CURLOPT_SSL_VERIFYPEER
    CURLOPT_SSL_VERIFYHOST
    CURLOPT_WRITEDATA
    CURLOPT_HEADERDATA
    CURLINFO_RESPONSE_CODE
    CURLOPT_TCP_NODELAY
);

has 'connect_timeout' => ( is => 'ro', default => 2 );

use namespace::clean;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri    = $self->build_uri($params);
    my $method = $params->{method};

    my $handle = $self->handle;
    $handle->reset;

    #    $handle->setopt( CURLOPT_VERBOSE,     1 );

    $handle->setopt( CURLOPT_HEADER,        0 );
    $handle->setopt( CURLOPT_TCP_NODELAY,   1 );
    $handle->setopt( CURLOPT_URL,           $uri );
    $handle->setopt( CURLOPT_CUSTOMREQUEST, $method );

    $handle->setopt( CURLOPT_CONNECTTIMEOUT_MS,
        $self->connect_timeout * 1000 );

    $handle->setopt( CURLOPT_TIMEOUT_MS,
        1000 * ( $params->{timeout} || $self->request_timeout ) );

    my %headers = %{ $self->default_headers };

    my $data = $params->{data};
    if ( defined $data ) {
        $headers{'Content-Type'} = $params->{mime_type};
        $headers{'Expect'}       = '';
        $handle->setopt( CURLOPT_POSTFIELDS,    $data );
        $handle->setopt( CURLOPT_POSTFIELDSIZE, length $data );
    }

    $handle->setopt( CURLOPT_HTTPHEADER,
        [ map { "$_: " . $headers{$_} } keys %headers ] )
        if %headers;

    if ( $self->is_https ) {
        $handle->setopt( CURLOPT_SSL_VERIFYPEER, 0 );
        $handle->setopt( CURLOPT_SSL_VERIFYHOST, 0 );
    }

    my $content = my $head = '';
    $handle->setopt( CURLOPT_WRITEDATA,  \$content );
    $handle->setopt( CURLOPT_HEADERDATA, \$head );

    my ( $code, $msg, $headers );

    try {
        $handle->perform;
        ( undef, undef, $code, $msg, $headers )
            = parse_http_response( $head, HEADERS_AS_HASHREF );
    }
    catch {
        $code = 509;
        $msg  = ( 0 + $_ ) . ": $_";
        $msg . ", " . $handle->error
            if $handle->error;
        undef $content;
    };

    return $self->process_response(
        $params,     # request
        $code,       # code
        $msg,        # msg
        $content,    # body
        $headers     # headers
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];
    shift;
    return
          m/^7:/  ? 'Cxn'
        : m/^28:/ ? 'Timeout'
        : m/^55:/ ? 'ContentLength'
        :           'Request';

}

#===================================
sub _build_handle { Net::Curl::Easy->new }
#===================================

1;

# ABSTRACT: DEPRECATED: A Cxn implementation which uses libcurl via Net::Curl

=head1 DESCRIPTION

=head1 DESCRIPTION

B<THIS MODULE IS DEPRECATED.>

******************************************************************************

Because of the name clash between C<ElasticSearch.pm> and C<Elasticsearch.pm>
this module has been renamed : L<Search::Elasticsearch::Cxn:NetCurl>.

See L<https://github.com/elasticsearch/elasticsearch-perl/issues/20> for details.

This distribution will be removed from CPAN in 2015. Please update your code.

******************************************************************************

Provides an HTTP Cxn class based on L<Net::Curl>.
The C<NetCurl> Cxn class is very fast and uses persistent connections but
requires XS and C<libcurl>.

This class does L<Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information.

=head1 CONFIGURATION

=head2 C<connect_timeout>

Unlike most HTTP backends, L<Net::Curl> accepts a separate C<connect_timeout>
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

=item * L<Elasticsearch::Cxn::Hijk>

=item * L<Elasticsearch::Cxn::LWP>

=item * L<Elasticsearch::Cxn::HTTPTiny>

=back

=head1 BUGS

This is a stable API but this implemenation is new. Watch this space
for new releases.

If you have any suggestions for improvements, or find any bugs, please report
them to L<http://github.com/elasticsearch/elasticsearch-perl/issues>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Elasticsearch::Cxn::NetCurl

You can also look for information at:

=over 4

=item * GitHub

L<http://github.com/elasticsearch/elasticsearch-perl>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Elasticsearch::Cxn::NetCurl>


=item * Search MetaCPAN

L<https://metacpan.org/module/Elasticsearch::Cxn::NetCurl>

=item * IRC

The L<#elasticsearch|irc://irc.freenode.net/elasticsearch> channel on
C<irc.freenode.net>.

=item * Mailing list

The main L<Elasticsearch mailing list|http://www.elasticsearch.org/community/forum/>.

=back

