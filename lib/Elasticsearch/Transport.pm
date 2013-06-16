package Elasticsearch::Transport;

use Moo;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use URI();
use List::Util qw(shuffle min);
use Time::HiRes qw(time);
use Try::Tiny;
use Elasticsearch::Util qw(parse_params);

has 'serializer' => (
    is       => 'ro',
    required => 1,
    handles  => { serialize => 'encode', deserialize => 'decode' }
);

has 'logger'           => ( is => 'ro', required => 1 );
has 'connection'       => ( is => 'ro', required => 1 );
has 'node_pool'        => ( is => 'ro', required => 1 );
has 'retry_connection' => ( is => 'ro', default  => 1 );
has 'retry_timeout'    => ( is => 'ro', default  => 1 );
has 'mime_type'        => ( is => 'lazy' );
has 'max_content_length' => ( is => 'ro' );

has 'path_prefix' => (
    is      => 'ro',
    default => sub {''},
    coerce  => sub {
        $_ = shift();
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
    my ( $self, $params ) = parse_params(@_);

    my $pool   = $self->node_pool;
    my $logger = $self->logger;

    my $method = $params->{method} ||= 'GET';
    my $path   = $params->{path}   ||= '/';
    $params->{qs}        ||= {};
    $params->{mime_type} ||= $self->mime_type;
    $params->{data}      ||= $self->serialize( $params->{body} );
    $params->{prefix} = $self->path_prefix;

    my ( $response, $node, $retry, $took );
    try {
        $node = $pool->next_node;

        my $start = time();
        $logger->infof( "%s %s%s", $method, $node, $path );
        $logger->trace_request( $node, $params, $start );

        my $raw = $self->connection->perform_request( $node, $params );
        $response = $self->deserialize($raw);

        my $end = time();
        $took = $end - $start;
        $logger->trace_response( $node, $response, $end, $took );
    }
    catch {
        my $error = upgrade_error($_);
        $retry = $self->handle_error( $node, $params, $error );
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
    my ( $self, $node, $params, $error ) = @_;

    my $logger = $self->logger;
    my $vars   = $error->{vars};

    $vars->{request} = $params;
    $vars->{node} = $node if $node;

    if ( $error->is( 'Connection', 'Timeout' ) ) {
        $logger->warn($error);
        $self->node_pool->mark_dead($node);
        return 1 if $self->should_retry( $node, $error, $params );
    }

    $logger->trace_error( $error, time() );

    if ( $error->is('Request') ) {
        return
            if $error->is('Missing')
            and $params->{ignore_missing};

        my $body = $self->deserialize( $vars->{body} );

        $error->{text}
            = !ref $body     ? delete $vars->{body}
            : $body->{error} ? "[$vars->{code}] $body->{error}"
            :                  $error->{text};

        $vars->{current_version} = $1
            if $error->is('Conflict')
            and $vars->{text} =~ /$Version_RE/;
    }

    $logger->throw_error($error);

}

#===================================
sub should_retry {
#===================================
    my ( $self, $node, $error ) = @_;
    return $error->is('Connection') && $self->retry_connection
        || $error->is('Timeout') && $self->retry_timeout;
}

1;

