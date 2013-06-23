package Elasticsearch::Transport;

use Moo;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use URI();
use Time::HiRes qw(time);
use Try::Tiny;
use Elasticsearch::Util qw(parse_params);

has 'serializer'       => ( is => 'ro', required => 1 );
has 'logger'           => ( is => 'ro', required => 1 );
has 'connection'       => ( is => 'ro', required => 1 );
has 'node_pool'        => ( is => 'ro', required => 1 );
has 'retry_connection' => ( is => 'ro', default  => 1 );
has 'retry_timeout'    => ( is => 'ro', default  => 1 );
has 'mime_type'        => ( is => 'lazy' );

has 'path_prefix' => (
    is      => 'ro',
    default => sub {''},
    coerce  => sub {
        local $_ = shift();
        s{^/?}{/};
        s{/$}{};
        $_;
    },
);

my $Version_RE = qr/: version conflict, current \[(\d+)\]/;

#===================================
sub _build_mime_type { shift->serializer->mime_type }
#===================================

#===================================
sub perform_request {
#===================================
    my $self   = shift;
    my $params = $self->tidy_request(@_);

    my $pool   = $self->node_pool;
    my $logger = $self->logger;

    my ( $response, $node, $retry, $start, $took );

    try {
        $node = $pool->next_node;

        $self->check_max_content_length($params);

        $start = time();
        $logger->infof( "%s %s%s", $params->{method}, $node,
            $params->{prefix} . $params->{path} );
        $logger->trace_request( $node, $params, $start );

        my $raw = $self->connection->perform_request( $node, $params );
        $response = $self->serializer->decode($raw);

        my $end = time();
        $took = $end - $start;
        $logger->trace_response( $node, $response, $end, $took );
    }
    catch {
        my $error = upgrade_error($_);
        $retry = $self->handle_error( $node, $params, $error );
        $took = time() - $start;
    };

    if ($retry) {
        $logger->debug('Retrying request on a new node');
        return $self->perform_request($params);
    }

    $logger->infof( "Took: %dms", $took * 1000 );
    return $response;
}

#===================================
sub handle_error {
#===================================
    my ( $self, $node, $request, $error ) = @_;

    my $logger = $self->logger;
    my $vars = $error->{vars} ||= {};

    delete $request->{data};
    $vars->{request} = $request;
    $vars->{node} = $node if $node;

    if ( $error->is( 'Connection', 'Timeout' ) ) {
        $self->node_pool->mark_dead($node);

        if ( $self->should_retry( $node, $error, $request ) ) {
            $logger->warn($error);
            return 1;
        }
    }

    $logger->trace_error( $error, time() );

    if ( $error->is('Request') ) {
        return
            if $error->is('Missing')
            and $request->{ignore_missing} || $request->{method} eq 'HEAD';

        my $body = $self->serializer->decode( $vars->{body} );
        $error->{text}
            = !ref $body     ? delete $vars->{body}
            : $body->{error} ? "[$vars->{code}] $body->{error}"
            :                  $error->{text};

        $vars->{current_version} = $1
            if $error->is('Conflict')
            and $vars->{body} =~ /$Version_RE/;

        $logger->info($error);
        throw($error);
    }

    $error->is('NoNodes')
        ? $logger->throw_critical($error)
        : $logger->throw_error($error);

}

#===================================
sub tidy_request {
#===================================
    my ( $self, $params ) = parse_params(@_);
    return $params if $params->{data};
    $params->{method}     ||= 'GET';
    $params->{path}       ||= '/';
    $params->{qs}         ||= {};
    $params->{mime_type}  ||= $self->mime_type;
    $params->{serializer} ||= 'std';
    $params->{prefix} = $self->path_prefix;

    my $body = $params->{body};
    return $params unless defined $body;

    $params->{data}
        = ( $params->{serializer} ||= 'std' )
        ? $self->serializer->encode($body)
        : $self->serializer->encode_bulk($body);

    return $params;

}

#===================================
sub check_max_content_length {
#===================================
    my ( $self, $params ) = @_;
    return unless defined $params->{data};

    my $max = $self->connection->max_content_length
        or return;

    return if length( $params->{data} ) < $max;

    $self->logger->throw_error( 'ContentLength',
        "Body is longer than max_content_length ($max)",
    );
}

#===================================
sub should_retry {
#===================================
    my ( $self, $node, $error ) = @_;
    return $error->is('Connection') && $self->retry_connection
        || $error->is('Timeout') && $self->retry_timeout;
}

1;

