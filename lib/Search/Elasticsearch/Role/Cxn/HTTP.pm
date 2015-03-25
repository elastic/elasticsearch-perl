package Search::Elasticsearch::Role::Cxn::HTTP;

use Moo::Role;

use URI();
use Search::Elasticsearch::Util qw(parse_params throw);
use namespace::clean;

has 'scheme'             => ( is => 'ro' );
has 'is_https'           => ( is => 'ro' );
has 'userinfo'           => ( is => 'ro' );
has 'max_content_length' => ( is => 'ro' );
has 'default_headers'    => ( is => 'ro' );
has 'ssl_options'        => ( is => 'ro', predicate => 'has_ssl_options' );
has 'handle'             => ( is => 'lazy', clearer => 1 );
has '_pid'               => ( is => 'rw', default => $$ );

#===================================
sub protocol     {'http'}
sub default_host {'http://localhost:9200'}
sub stringify    { shift->uri . '' }
#===================================

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);

    my $node = $params->{node}
        || { host => 'localhost', port => '9200' };

    unless ( ref $node eq 'HASH' ) {
        unless ( $node =~ m{^http(s)?://} ) {
            $node = ( $params->{use_https} ? 'https://' : 'http://' ) . $node;
        }
        if ( $params->{port} && $node !~ m{//[^/]+:\d+} ) {
            $node =~ s{(//[^/]+)}{$1:$params->{port}};
        }
        my $uri = URI->new($node);
        $node = {
            scheme   => $uri->scheme,
            host     => $uri->host,
            port     => $uri->port,
            path     => $uri->path,
            userinfo => $uri->userinfo
        };
    }

    my $host = $node->{host} || 'localhost';
    my $userinfo = $node->{userinfo} || $params->{userinfo} || '';
    my $scheme
        = $node->{scheme} || ( $params->{use_https} ? 'https' : 'http' );
    my $port
        = $node->{port}
        || $params->{port}
        || ( $scheme eq 'http' ? 80 : 443 );
    my $path = $node->{path} || $params->{path_prefix} || '';
    $path =~ s{^/?}{/}g;
    $path =~ s{/+$}{};

    my %default_headers = %{ $params->{default_headers} || {} };

    if ($userinfo) {
        require MIME::Base64;
        my $auth = MIME::Base64::encode_base64($userinfo);
        chomp $auth;
        $default_headers{Authorization} = "Basic $auth";
    }

    if ( $params->{deflate} ) {
        $default_headers{'Accept-Encoding'} = "deflate";
    }

    $params->{scheme}          = $scheme;
    $params->{is_https}        = $scheme eq 'https';
    $params->{host}            = $host;
    $params->{port}            = $port;
    $params->{path}            = $path;
    $params->{userinfo}        = $userinfo;
    $params->{uri}             = URI->new("$scheme://$host:$port$path");
    $params->{default_headers} = \%default_headers;

    return $params;

}

#===================================
sub build_uri {
#===================================
    my ( $self, $params ) = @_;
    my $uri = $self->uri->clone;
    $uri->path( $uri->path . $params->{path} );
    $uri->query_form( $params->{qs} );
    return $uri;
}

#===================================
before 'perform_request' => sub {
#===================================
    my ( $self, $params ) = @_;
    return unless defined $params->{data};

    my $max = $self->max_content_length
        or return;

    return if length( $params->{data} ) < $max;

    $self->logger->throw_error( 'ContentLength',
        "Body is longer than max_content_length ($max)",
    );
};

#===================================
before 'handle' => sub {
#===================================
    my $self = shift;
    if ( $$ != $self->_pid ) {
        $self->clear_handle;
        $self->_pid($$);
    }
};

#===================================
around 'process_response' => sub {
#===================================
    my ( $orig, $self, $params, $code, $msg, $body, $headers ) = @_;

    if ( my $encoding = $headers->{'content-encoding'} ) {
        $body = $self->inflate($body)
            if $encoding eq 'deflate';
    }

    my ($mime_type) = split /\s*;\s*/, ( $headers->{'content-type'} || '' );
    $orig->( $self, $params, $code, $msg, $body, $mime_type );
};

#===================================
sub inflate {
#===================================
    my $self    = shift;
    my $content = shift;

    my $output;
    require IO::Uncompress::Inflate;
    no warnings 'once';

    IO::Uncompress::Inflate::inflate( \$content, \$output, Transparent => 0 )
        or throw( 'Request',
        "Couldn't inflate response: $IO::Uncompress::Inflate::InflateError" );

    return $output;
}

1;

# ABSTRACT: Provides common functionality to HTTP Cxn implementations

=head1 DESCRIPTION

L<Search::Elasticsearch::Role::Cxn::HTTP> provides common functionality to the Cxn
implementations which use the HTTP protocol. Cxn instances are created by a
L<Search::Elasticsearch::Role::CxnPool> implementation, using the
L<Search::Elasticsearch::Cxn::Factory> class.

=head1 CONFIGURATION

The configuration options are as follows:

=head2 C<node>

A single C<node> is passed to C<new()> by the L<Search::Elasticsearch::Cxn::Factory>
class.  It can either be a URI or a hash containing each part.  For instance:

    node => 'localhost';                    # equiv of 'http://localhost:80'
    node => 'localhost:9200';               # equiv of 'http://localhost:9200'
    node => 'http://localhost:9200';

    node => 'https://localhost';            # equiv of 'https://localhost:443'
    node => 'localhost/path';               # equiv of 'http://localhost:80/path'


    node => 'http://user:pass@localhost';   # equiv of 'http://localhost:80'
                                            # with userinfo => 'user:pass'

Alternatively, a C<node> can be specified as a hash:

    {
        scheme      => 'http',
        host        => 'search.domain.com',
        port        => '9200',
        path        => '/path',
        userinfo    => 'user:pass'
    }

Similarly, default values can be specified with C<port>, C<path_prefix>,
C<userinfo> and C<use_https>:

    $e = Search::Elasticsearch->new(
        port        => 9201,
        path_prefix => '/path',
        userinfo    => 'user:pass',
        use_https   => 1,
        nodes       => [ 'search1', 'search2' ]
    )

=head2 C<ssl_options>

By default, all backends that support HTTPS disable verification of
the host they are connecting to.  Use C<ssl_options> to configure
the type of verification that you would like the client to perform,
or to configure the client to present its own certificate.

The values accepted by C<ssl_options> depend on the C<Cxn> class.  See the
documentation for the C<Cxn> class that you are using.

=head2 C<max_content_length>

By default, Elasticsearch nodes accept a maximum post body of 100MB or
C<104_857_600> bytes. This client enforces that limit.  The limit can
be customised with the C<max_content_length> parameter (specified in bytes).

If you're using the L<Search::Elasticsearch::CxnPool::Sniff> module, then the
C<max_content_length> will be automatically retrieved from the live cluster,
unless you specify a custom C<max_content_length>:

    # max_content_length retrieved from cluster
    $e = Search::Elasticsearch->new(
        cxn_pool => 'Sniff'
    );

    # max_content_length fixed at 10,000 bytes
    $e = Search::Elasticsearch->new(
        cxn_pool           => 'Sniff',
        max_content_length => 10_000
    );

=head2 C<deflate>

This client can request compressed responses from Elasticsearch by
enabling the C<http.compression> config setting in
L<Elasticsearch|http://www.elastic.co/guide/reference/modules/http/>
and setting C<deflate> to C<true>:

    $e = Search::Elasticsearch->new(
        deflate => 1
    );

=head1 METHODS

None of the methods listed below are useful to the user. They are
documented for those who are writing alternative implementations only.

=head2 C<scheme()>

    $scheme = $cxn->scheme;

Returns the scheme of the connection, ie C<http> or C<https>.

=head2 C<is_https()>

    $bool = $cxn->is_https;

Returns C<true> or C<false> depending on whether the C</scheme()> is C<https>
or not.

=head2 C<userinfo()>

    $userinfo = $cxn->userinfo

Returns the username and password of the cxn, if any, eg C<"user:pass">.
If C<userinfo> is provided, then a Basic Authorization header is added
to each request.

=head2 C<default_headers()>

    $headers = $cxn->default_headers

The default headers that are passed with each request.  This includes
the C<Accept-Encoding> header if C</deflate> is true, and the C<Authorization>
header if C</userinfo> has a value.

=head2 C<max_content_length()>

    $int = $cxn->max_content_length;

Returns the maximum length in bytes that the HTTP body can have.

=head2 C<build_uri()>

    $uri = $cxn->build_uri({ path => '/_search', qs => { size => 10 }});

Returns the HTTP URI to use for a particular request, combining the passed
in C<path> parameter with any defined C<path_prefix>, and adding the
query-string parameters.
