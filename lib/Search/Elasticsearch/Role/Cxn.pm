package Search::Elasticsearch::Role::Cxn;

use Moo::Role;
use Search::Elasticsearch::Util qw(throw);
use List::Util qw(min);
use Try::Tiny;
use URI();
use Search::Elasticsearch::Util qw(to_list);
use namespace::clean;

requires qw(protocol perform_request error_from_text);

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

my %Code_To_Error = (
    400 => 'Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Missing',
    408 => 'RequestTimeout',
    409 => 'Conflict',
    503 => 'Unavailable'
);

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
    my $self     = shift;
    my $protocol = $self->protocol;
    $self->logger->infof( 'Sniffing [%s]', $self->stringify );
    return try {
        $self->perform_request(
            {   method  => 'GET',
                path    => '/_nodes/' . $protocol,
                qs      => { timeout => 1000 * $self->sniff_timeout },
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
sub process_response {
#===================================
    my ( $self, $params, $code, $msg, $body, $mime_type ) = @_;

    my $is_encoded = $mime_type && $mime_type ne 'text/plain';

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
            and $msg =~ /: version conflict, current \[(\d+)\]/;
    }
    $msg ||= $error_type;

    chomp $msg;
    throw( $error_type, "[" . $self->stringify . "]-[$code] $msg",
        \%error_args );
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
            = "["
            . ( delete $cause{type} ) . "] "
            . ( delete $cause{reason} );
        if ( keys %cause ) {
            $msg .= ", with: " . $json->encode( \%cause );
        }
        push @msgs, $msg;
    }
    return ( join ", ", @msgs );
}

1;

# ABSTRACT: Provides common functionality to Cxn implementations

=head1 DESCRIPTION

L<Search::Elasticsearch::Role::Cxn> provides common functionality to the Cxn
implementations. Cxn instances are created by a L<Search::Elasticsearch::Role::CxnPool>
implementation, using the L<Search::Elasticsearch::Cxn::Factory> class.

=head1 CONFIGURATION

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

