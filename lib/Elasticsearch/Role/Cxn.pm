package Elasticsearch::Role::Cxn;

use Moo::Role;
with 'Elasticsearch::Role::Error';
use List::Util qw(min);
use Try::Tiny;
use URI();
use Elasticsearch::Util qw(to_list);
use namespace::autoclean;

requires qw(protocol perform_request error_from_text);

has 'host'                  => ( is => 'ro', required => 1 );
has 'port'                  => ( is => 'ro', required => 1 );
has 'uri'                   => ( is => 'ro', required => 1 );
has 'request_timeout'       => ( is => 'ro', default  => 10 );
has 'ping_timeout'          => ( is => 'ro', default  => 0.3 );
has 'sniff_timeout'         => ( is => 'ro', default  => 0.2 );
has 'sniff_request_timeout' => ( is => 'ro', default  => 0.3 );
has 'next_ping'             => ( is => 'rw', default  => 0 );
has 'ping_failures'         => ( is => 'rw', default  => 0 );
has 'dead_timeout'          => ( is => 'ro', default  => 60 );
has 'max_dead_timeout'      => ( is => 'ro', default  => 3600 );
has 'serializer'            => ( is => 'ro', required => 1 );
has 'logger'                => ( is => 'ro', required => 1 );
has 'handle_args'           => ( is => 'ro', default  => sub { {} } );

my %Code_To_Error = (
    400 => 'Request',
    403 => 'ClusterBlocked',
    404 => 'Missing',
    409 => 'Conflict',
    500 => 'Request',
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
            {   method => 'GET',
                path   => '/_cluster/nodes',
                qs     => {
                    timeout   => 1000 * $self->sniff_timeout,
                    $protocol => 1
                },
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
    my ( $self, $params, $code, $msg, $body ) = @_;
    $code ||= 500;

    if ( $code >= 200 and $code <= 209 ) {
        return ( $code, $self->serializer->decode($body) )
            if length $body;
        return ( $code, 1 ) if $params->{method} eq 'HEAD';
        return ( $code, '' );
    }

    my @ignore = to_list( $params->{ignore} );
    push @ignore, 404 if $params->{method} eq 'HEAD';
    return ($code) if grep { $_ eq $code } @ignore;

    my $error_type = $Code_To_Error{$code};
    unless ($error_type) {
        if ( defined $body ) {
            $msg  = $body;
            $body = undef;
        }
        $error_type = $self->error_from_text( $code, $msg );
    }

    my %error_args = ( status_code => $code, request => $params );

    if ( $body = $self->serializer->decode($body) ) {
        $error_args{body} = $body;
        if ( ref $body ) {
            $msg = $body->{error} || $msg;
        }
        else {
            $msg = $body;
        }

        $error_args{current_version} = $1
            if $error_type eq 'Conflict'
            and $msg =~ /: version conflict, current \[(\d+)\]/;
    }

    chomp $msg;
    throw( $error_type, "[" . $self->stringify . "]-[$code] $msg",
        \%error_args );
}

1;
