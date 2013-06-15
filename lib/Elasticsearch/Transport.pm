package Elasticsearch::Transport;

use strict;
use warnings;
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params init_instance);
use Elasticsearch::Error qw(throw upgrade_error);
use URI();
use List::Util qw(shuffle min);
use Try::Tiny;

my @Required_Params = qw(serializer logger tracer connection node_pool);
my $Version_RE      = qr/: version conflict, current \[(\d+)\]/;

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $self = bless {
        retry_connection   => 1,
        retry_timeout      => 1,
        max_content_length => 104_857_600,
    }, $class;

    init_instance( $self, \@Required_Params, $params );

    return $self;

}

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = parse_params(@_);

    my $request = $self->prepare_request($params);

    # trace request
    my $pool = $self->node_pool;

    my ( $response, $node );

    while (1) {
        try {
            $node = $pool->next_node;
            my $raw = $self->cxn->perform_request( $node, $request );
            $response = $self->deserialize($raw);
            1;
        }
        catch {
            my $error = upgrade_error($_);

            $pool->mark_dead($node)
                if $error->is( 'Connection', 'Timeout' );

            my $vars = $error->{vars};
            $vars->{request} = $request;
            $vars->{node} = $node if $node;

            if ( $error->is('Request') ) {
                try { $vars->{body} = $self->deserialize( $vars->{body} ) };

                $vars->{current_version} = $1
                    if $error->is('Conflict')
                    and $vars->{error} =~ /$Version_RE/;

                if ( $error->is('Missing') ) {
                    return 1 if $params->{ignore_missing};
                }
            }

            if ( $self->should_retry( $node, $error, $request ) ) {

                # warn $error
            }
            else {
                die $error;
            }
            return;
        }
            and last;
    }
    return $response;
}

#===================================
sub prepare_request {
#===================================
    my ( $self, $params ) = @_;

    my $body = $params->{body};

    my $request = {
        method => $params->{method} || 'GET',
        path   => $params->{path}   || '/',
        qs     => $params->{qs}     || {},
    };

    if ( defined $body ) {
        if ( ref $body ) {
            $body = $self->serialize($body)
                if ref $body;
        }
        else {
            #encode utf8?
        }
        $request->{body} = $body;
    }
    return $request;
}

#===================================
sub should_retry {
#===================================
    my ( $self, $node, $error ) = @_;
    return $error->is('Connection') && $self->retry_connection
        || $error->is('Timeout') && $self->retry_timeout;
}

#===================================
sub node_pool        { $_[0]->{node_pool} }
sub connection       { $_[0]->{connection} }
sub cxn              { $_[0]->{connection} }
sub serializer       { $_[0]->{serializer} }
sub retry_connection { $_[0]->{retry_connection} }
sub retry_timeout    { $_[0]->{retry_timeout} }
sub serialize        { shift()->serializer->encode(@_) }
sub deserialize      { shift()->serializer->decode(@_) }
#===================================

1;

