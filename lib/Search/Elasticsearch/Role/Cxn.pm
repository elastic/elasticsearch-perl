package Search::Elasticsearch::Role::Cxn;

use Moo::Role;
use Search::Elasticsearch::Util qw(parse_params throw to_list);
use List::Util qw(min);
use Try::Tiny;
use URI();
use IO::Compress::Deflate();
use IO::Uncompress::Inflate();
use IO::Compress::Gzip();
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Search::Elasticsearch::Util qw(to_list);
use namespace::clean;
use Net::IP;

requires qw(perform_request error_from_text handle);

has 'host'                  => ( is => 'ro', required => 1 );
has 'port'                  => ( is => 'ro', required => 1 );
has 'uri'                   => ( is => 'ro', required => 1 );
has 'request_timeout'       => ( is => 'ro', default  => 30 );
has 'ping_timeout'          => ( is => 'ro', default  => 2 );
has 'sniff_timeout'         => ( is => 'ro', default  => 1 );
has 'sniff_request_timeout' => ( is => 'ro', default  => 2 );
has 'next_ping'             => ( is => 'rw', default  => 0 );
has 'ping_failures'         => ( is => 'rw', default  => 0 );
has 'dead_timeout'          => ( is => 'ro', default  => 60 );
has 'max_dead_timeout'      => ( is => 'ro', default  => 3600 );
has 'serializer'            => ( is => 'ro', required => 1 );
has 'logger'                => ( is => 'ro', required => 1 );
has 'handle_args'           => ( is => 'ro', default  => sub { {} } );
has 'default_qs_params'     => ( is => 'ro', default  => sub { {} } );
has 'scheme'             => ( is => 'ro' );
has 'is_https'           => ( is => 'ro' );
has 'userinfo'           => ( is => 'ro' );
has 'max_content_length' => ( is => 'ro' );
has 'default_headers'    => ( is => 'ro' );
has 'deflate'            => ( is => 'ro' );
has 'gzip'               => ( is => 'ro' );
has 'ssl_options'        => ( is => 'ro', predicate => 'has_ssl_options' );
has 'handle'             => ( is => 'lazy', clearer => 1 );
has '_pid'               => ( is => 'rw', default => $$ );

my %Code_To_Error = (
    400 => 'Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Missing',
    408 => 'RequestTimeout',
    409 => 'Conflict',
    413 => 'ContentLength',
    502 => 'BadGateway',
    503 => 'Unavailable',
    504 => 'GatewayTimeout'
);

#===================================
sub stringify { shift->uri . '' }
#===================================

#===================================
sub get_user_agent {
#===================================
    return sprintf("elasticsearch-perl/%s- (PERL %s)", $Search::Elasticsearch::VERSION, $]);
}

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);

    my $node = $params->{node}
        || { host => 'localhost', port => '9200' };

    unless ( ref $node eq 'HASH' ) {
        $node = "[$node]" if Net::IP::ip_is_ipv6($node);
        unless ( $node =~ m{^http(s)?://} ) {
            $node = ( $params->{use_https} ? 'https://' : 'http://' ) . $node;
        }
        if ( $params->{port} && $node !~ m{//[^/\[]+:\d+} ) {
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
        my $auth = MIME::Base64::encode_base64( $userinfo, "" );
        chomp $auth;
        $default_headers{Authorization} = "Basic $auth";
    }

    if ( $params->{gzip} ) {
        $default_headers{'Accept-Encoding'} = "gzip";
    }

    elsif ( $params->{deflate} ) {
        $default_headers{'Accept-Encoding'} = "deflate";
    }

    $default_headers{'User-Agent'} = $class->get_user_agent();

    $params->{scheme}   = $scheme;
    $params->{is_https} = $scheme eq 'https';
    $params->{host}     = $host;
    $params->{port}     = $port;
    $params->{path}     = $path;
    $params->{userinfo} = $userinfo;
    $host = "[$host]" if Net::IP::ip_is_ipv6($host);
    $params->{uri}             = URI->new("$scheme://$host:$port$path");
    $params->{default_headers} = \%default_headers;

    return $params;
}

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
sub is_live { !shift->next_ping }
sub is_dead { !!shift->next_ping }
#===================================

#===================================
sub mark_live {
#===================================
    my $self = shift;
    $self->ping_failures(0);
    $self->next_ping(0);
}

#===================================
sub mark_dead {
#===================================
    my $self  = shift;
    my $fails = $self->ping_failures;
    $self->ping_failures( $fails + 1 );

    my $timeout
        = min( $self->dead_timeout * 2**$fails, $self->max_dead_timeout );
    my $next = $self->next_ping( time() + $timeout );

    $self->logger->infof( 'Marking [%s] as dead. Next ping at: %s',
        $self->stringify, scalar localtime($next) );

}

#===================================
sub force_ping {
#===================================
    my $self = shift;
    $self->ping_failures(0);
    $self->next_ping(-1);
}

#===================================
sub pings_ok {
#===================================
    my $self = shift;
    $self->logger->infof( 'Pinging [%s]', $self->stringify );
    return try {
        $self->perform_request(
            {   method  => 'HEAD',
                path    => '/',
                timeout => $self->ping_timeout,
            }
        );
        $self->logger->infof( 'Marking [%s] as live', $self->stringify );
        $self->mark_live;
        1;
    }
    catch {
        $self->logger->debug("$_");
        $self->mark_dead;
        0;
    };
}

#===================================
sub sniff {
#===================================
    my $self = shift;
    $self->logger->infof( 'Sniffing [%s]', $self->stringify );
    return try {
        $self->perform_request(
            {   method  => 'GET',
                path    => '/_nodes/http',
                qs      => { timeout => $self->sniff_timeout . 's' },
                timeout => $self->sniff_request_timeout,
            }
        )->{nodes};
    }
    catch {
        $self->logger->debug($_);
        return;
    };
}

#===================================
sub build_uri {
#===================================
    my ( $self, $params ) = @_;
    my $uri = $self->uri->clone;
    $uri->path( $uri->path . $params->{path} );
    my %qs = ( %{ $self->default_qs_params }, %{ $params->{qs} || {} } );
    $uri->query_form( \%qs );
    return $uri;
}

#===================================
before 'perform_request' => sub {
#===================================
    my ( $self, $params ) = @_;
    return unless defined $params->{data};

    $self->_compress_body($params);

    my $max = $self->max_content_length
        or return;

    return if length( $params->{data} ) < $max;

    $self->logger->throw_error( 'ContentLength',
        "Body is longer than max_content_length ($max)",
    );
};

#===================================
sub _compress_body {
#===================================
    my ( $self, $params ) = @_;
    my $output;
    if ( $self->gzip ) {
        IO::Compress::Gzip::gzip( \( $params->{data} ), \$output )
            or throw( 'Request',
            "Couldn't gzip request: $IO::Compress::Gzip::GzipError" );
        $params->{data}     = $output;
        $params->{encoding} = 'gzip';
    }
    elsif ( $self->deflate ) {
        IO::Compress::Deflate::deflate( \( $params->{data} ), \$output )
            or throw( 'Request',
            "Couldn't deflate request: $IO::Compress::Deflate::DeflateError" );
        $params->{data}     = $output;
        $params->{encoding} = 'deflate';
    }
}

#===================================
sub _decompress_body {
#===================================
    my ( $self, $body_ref, $headers ) = @_;
    if ( my $encoding = $headers->{'content-encoding'} ) {
        my $output;
        if ( $encoding eq 'gzip' ) {
            IO::Uncompress::Gunzip::gunzip( $body_ref, \$output )
                or throw(
                'Request',
                "Couldn't gunzip response: $IO::Uncompress::Gunzip::GunzipError"
                );
        }
        elsif ( $encoding eq 'deflate' ) {
            IO::Uncompress::Inflate::inflate( $body_ref, \$output,
                Transparent => 0 )
                or throw(
                'Request',
                "Couldn't inflate response: $IO::Uncompress::Inflate::InflateError"
                );
        }
        else {
            throw( 'Request', "Unknown content-encoding: $encoding" );
        }
        ${$body_ref} = $output;
    }
}

#===================================
sub process_response {
#===================================
    my ( $self, $params, $code, $msg, $body, $headers ) = @_;
    $self->_decompress_body( \$body, $headers );

    my ($mime_type) = split /\s*;\s*/, ( $headers->{'content-type'} || '' );

    my $is_encoded = $mime_type && $mime_type ne 'text/plain';

    # Deprecation warnings
    if ( my $warnings = $headers->{warning} ) {
        my $warning_string = _parse_warnings($warnings);
        my %temp           = (%$params);
        delete $temp{data};
        $self->logger->deprecation( $warning_string, \%temp );
    }

    # Request is successful

    if ( $code >= 200 and $code <= 209 ) {
        if ( defined $body and length $body ) {
            $body = $self->serializer->decode($body)
                if $is_encoded;
            return $code, $body;
        }
        return ( $code, 1 ) if $params->{method} eq 'HEAD';
        return ( $code, '' );
    }

    # Check if the error should be ignored
    my @ignore = to_list( $params->{ignore} );
    push @ignore, 404 if $params->{method} eq 'HEAD';
    return ($code) if grep { $_ eq $code } @ignore;

    # Determine error type
    my $error_type = $Code_To_Error{$code};
    unless ($error_type) {
        if ( defined $body and length $body ) {
            $msg  = $body;
            $body = undef;
        }
        $error_type = $self->error_from_text( $code, $msg );
    }

    delete $params->{data} if $params->{body};
    my %error_args = ( status_code => $code, request => $params );

    # Extract error message from the body, if present

    if ( $body = $self->serializer->decode($body) ) {
        $error_args{body} = $body;
        $msg = $self->_munge_elasticsearch_exception($body) || $msg;

        $error_args{current_version} = $1
            if $error_type eq 'Conflict'
            and $msg =~ /: version conflict, current (?:version )?\[(\d+)\]/;
    }
    $msg ||= $error_type;

    chomp $msg;
    throw( $error_type, "[" . $self->stringify . "]-[$code] $msg",
        \%error_args );
}

#===================================
sub _parse_warnings {
#===================================
    my @warnings = ref $_[0] eq 'ARRAY' ? @{ shift() } : shift();
    my @str;
    for (@warnings) {
        if ( $_ =~ /^\d+\s+\S+\s+"((?:\\"|[^"])+)"/ ) {
            my $msg = $1;
            $msg =~ s/\\"/"/g, push @str, $msg;
        }
        else {
            push @str, $_;
        }
    }
    return join "; ", @str;
}

#===================================
sub _munge_elasticsearch_exception {
#===================================
    my ( $self, $body ) = @_;
    return $body unless ref $body eq 'HASH';
    my $error = $body->{error} || return;
    return $error unless ref $error eq 'HASH';

    my $root_causes = $error->{root_cause} || [];
    unless (@$root_causes) {
        my $msg = "[" . $error->{type} . "] " if $error->{type};
        $msg .= $error->{reason} if $error->{reason};
        return $msg;
    }

    my $json = $self->serializer;
    my @msgs;
    for (@$root_causes) {
        my %cause = (%$_);
        my $msg
            = "[" . ( delete $cause{type} ) . "] " . ( delete $cause{reason} );
        if ( keys %cause ) {
            $msg .= ", with: " . $json->encode( \%cause );
        }
        push @msgs, $msg;
    }
    return ( join ", ", @msgs );
}

1;

# ABSTRACT: Provides common functionality to HTTP Cxn implementations

=head1 DESCRIPTION

L<Search::Elasticsearch::Role::Cxn> provides common functionality to Cxn
implementations. Cxn instances are created by a
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

=head2 C<gzip>

Enable Gzip compression of requests to and responses from Elasticsearch
as follows:

    $e = Search::Elasticsearch->new(
        gzip => 1
    );

=head2 C<deflate>

Enable Inflate/Deflate compression of requests to and responses from Elasticsearch
as follows:

    $e = Search::Elasticsearch->new(
        deflate => 1
    );


B<IMPORTANT:> The L</request_timeout>, L</ping_timeout>, L</sniff_timeout>,
and L</sniff_request_timeout> parameters default to values that allow
this module to function with low powered hardware and slow networks.
When you use Elasticsearch in production, you will probably want to reduce
these timeout parameters to values that suit your environment.

The configuration parameters are as follows:

=head2 C<request_timeout>

    $e = Search::Elasticsearch->new(
        request_timeout => 30
    );

How long a normal request (ie not a ping or sniff request) should wait
before throwing a C<Timeout> error.  Defaults to C<30> seconds.

B<Note:> In production, no CRUD or search request should take 30 seconds to run,
although admin tasks like C<upgrade()>, C<optimize()>, or snapshot C<create()>
may take much longer. A more reasonable value for production would be
C<10> seconds or lower.

=head2 C<ping_timeout>

    $e = Search::Elasticsearch->new(
        ping_timeout => 2
    );

How long a ping request should wait before throwing a C<Timeout> error.
Defaults to C<2> seconds. The L<Search::Elasticsearch::CxnPool::Static> module
pings nodes on first use, after any failure, and periodically to ensure
that nodes are healthy. The C<ping_timeout> should be long enough to allow
nodes respond in time, but not so long that sick nodes cause delays.
A reasonable value for use in production on reasonable hardware
would be C<0.3>-C<1> seconds.

=head2 C<dead_timeout>

    $e = Search::Elasticsearch->new(
        dead_timeout => 60
    );

How long a Cxn should be considered to be I<dead> (not used to serve requests),
before it is retried.  The default is C<60> seconds.  This value is increased
by powers of 2 for each time a request fails.  In other words, the delay
after each failure is as follows:

    Failure     Delay
    1           60 * 1  = 60 seconds
    2           60 * 2  = 120 seconds
    3           60 * 4  = 240 seconds
    4           60 * 8  = 480 seconds
    5           60 * 16 = 960 seconds

=head2 C<max_dead_timeout>

    $e = Search::Elasticsearch->new(
        max_dead_timeout => 3600
    );

The maximum delay that should be applied to a failed node. If the
L</dead_timeout> calculation results in a delay greater than
C<max_dead_timeout> (default C<3,600> seconds) then the C<max_dead_timeout>
is used instead.  In other words, dead nodes will be retried at least once
every hour by default.

=head2 C<sniff_request_timeout>

    $e = Search::Elasticsearch->new(
        sniff_request_timeout => 2
    );

How long a sniff request should wait before throwing a C<Timeout> error.
Defaults to C<2> seconds. A reasonable value for production would be
C<0.5>-C<2> seconds.

=head2 C<sniff_timeout>

    $e = Search::Elasticsearch->new(
        sniff_timeout => 1
    );

How long the node being sniffed should wait for responses from other nodes
before responding to the client.  Defaults to C<1> second. A reasonable
value in production would be C<0.3>-C<1> seconds.

B<Note:> The C<sniff_timeout> is distinct from the L</sniff_request_timeout>.
For example, let's say you have a cluster with 5 nodes, 2 of which are
unhealthy (taking a long time to respond):

=over

=item *

If you sniff an unhealthy node, the request will throw a C<Timeout> error
after C<sniff_request_timeout> seconds.

=item *

If you sniff a healthy node, it will gather responses from the other nodes,
and give up after C<sniff_timeout> seconds, returning just the information it
has managed to gather from the healthy nodes.

=back

B<NOTE:> The C<sniff_request_timeout> must be longer than the C<sniff_timeout>
to ensure that you get information about healthy nodes from the cluster.

=head2 C<handle_args>

Any default arguments which should be passed when creating a new instance of
the class which handles the network transport, eg L<HTTP::Tiny>.

=head2 C<default_qs_params>

    $e = Search::Elasticsearch->new(
        default_qs_params => {
            session_key => 'my_session_key'
        }
    );

Any values passed to C<default_qs_params> will be added to the query string
of every request. Also see L<Search::Elasticsearch::Role::Cxn::HTTP/default_headers()>.


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
Also see L<Search::Elasticsearch::Role::Cxn/default_qs_params>.

=head2 C<max_content_length()>

    $int = $cxn->max_content_length;

Returns the maximum length in bytes that the HTTP body can have.

=head2 C<build_uri()>

    $uri = $cxn->build_uri({ path => '/_search', qs => { size => 10 }});

Returns the HTTP URI to use for a particular request, combining the passed
in C<path> parameter with any defined C<path_prefix>, and adding the
query-string parameters.

=head1 METHODS

None of the methods listed below are useful to the user. They are
documented for those who are writing alternative implementations only.

=head2 C<host()>

    $host = $cxn->host;

The value of the C<host> parameter, eg C<search.domain.com>.

=head2 C<port()>

    $port = $cxn->port;

The value of the C<port> parameter, eg C<9200>.

=head2 C<uri()>

    $uri = $cxn->uri;

A L<URI> object representing the node, eg C<https://search.domain.com:9200/path>.

=head2 C<is_dead()>

    $bool = $cxn->is_dead

Is the current node marked as I<dead>.

=head2 C<is_live()>

    $bool = $cxn->is_live

Is the current node marked as I<live>.

=head2 C<next_ping()>

    $time = $cxn->next_ping($time)

Get/set the time for the next scheduled ping.  If zero, no ping is scheduled
and the cxn is considered to be alive.  If -1, a ping is scheduled before
the next use.

=head2 C<ping_failures()>

    $num = $cxn->ping_failures($num)

The number of times that a cxn has been marked as dead.

=head2 C<mark_dead()>

    $cxn->mark_dead

Mark the cxn as I<dead>, set L</next_ping()> and increment L</ping_failures()>.

=head2 C<mark_live()>

Mark the cxn as I<live>, set L</next_ping()> and L</ping_failures()> to zero.

=head2 C<force_ping()>

Set L</next_ping()> to -1 (ie before next use) and L</ping_failures()> to zero.

=head2 C<pings_ok()>

    $bool = $cxn->pings_ok

Try to ping the node and call L</mark_live()> or L</mark_dead()> depending on
the success or failure of the ping.

=head2 C<sniff()>

    $response = $cxn->sniff;

Send a sniff request to the node and return the response.

=head2 C<process_response()>

    ($code,$result) = $cxn->process_response($params, $code, $msg, $body );

Processes the response received from an Elasticsearch node and either
returns the HTTP status code and the response body (deserialized from JSON)
or throws an error of the appropriate type.

The C<$params> are the original params passed to
L<Search::Elasticsearch::Transport/perform_request()>, the C<$code> is the HTTP
status code, the C<$msg> is the error message returned by the backend
library and the C<$body> is the HTTP response body returned by
Elasticsearch.

