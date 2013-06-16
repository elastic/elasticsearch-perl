package Elasticsearch::Logger;

use Moo;
use namespace::autoclean;
use Log::Any();
use Elasticsearch::Util qw(parse_params init_instance);
use URI();

has 'serializer' => ( is => 'ro', required => 1 );
has 'logger' => (
    is      => 'ro',
    default => sub { Log::Any->get_logger( category => 'elasticsearch' ) },
    handles => [
        qw(debug debugf info infof warn warnf error errorf
           critical criticalf is_debug is_info)
    ]
);
has 'tracer' => ( is => 'ro' );

#===================================
sub BUILDARGS {
#===================================
    my $class = shift;
    my %params = ref $_[0] ? %{shift()}: @_;

    if ( my $args = delete $params{logger} ) {
        $args = [$args] unless ref $args eq 'ARRAY';
        Log::Any::Adapter->set( { category => 'elasticsearch' }, @$args );
    }

    if ( my $args = $params{tracer} ) {
        $args = [$args] unless ref $args eq 'ARRAY';
        Log::Any::Adapter->set( { category => 'elasticsearch.trace' },
            @$args );
        $params{tracer}
            = Log::Any->get_logger( category => 'elasticsearch.trace' );
    }
    return \%params;
}


#===================================
sub throw_error {
#===================================
    my ( $self, $type, $msg, $vars ) = @_;
    my $error = Elasticsearch::Error->new( $type, $msg, $vars, 1 );
    $self->error($error);
    die $error;
}

#===================================
sub throw_critical {
#===================================
    my ( $self, $type, $msg, $vars ) = @_;
    my $error = Elasticsearch::Error->new( $type, $msg, $vars, 1 );
    $self->critical($error);
    die $error;
}

#===================================
sub trace_request {
#===================================
    my ( $self, $node, $request, $time ) = @_;
    my $tracer = $self->{tracer} or return;

    my $uri = URI->new();
    $uri->query_form( %{ $request->{qs} }, pretty => 1 );

    my $body = $self->serializer->encode_pretty( $request->{body} );
    if ( defined $body ) {
        $body =~ s/'/\u0027/g;
        $body = " -d '\n$body'";
    }
    else { $body = '' }

    my $msg = sprintf(
        "# [%s] Node: %s\n"                             #
            . "curl -X%s 'localhost:9200%s%s' %s\n",    #
        localtime($time) . '',
        $node,
        $request->{method},
        $request->{path},
        $uri,
        $body
    );

    $tracer->trace($msg);
}

#===================================
sub trace_response {
#===================================
    my ( $self, $node, $response, $time, $took ) = @_;
    my $tracer = $self->{tracer} or return;

    my $body = $self->serializer->encode_pretty($response)
        || '<NO BODY>';
    $body =~ s/^/# /mg;

    my $msg = sprintf(
        "# [%s] Took:%dms\n%s",
        scalar localtime($time),
        $took * 1000, $body
    );

    $tracer->trace($msg);
}

#===================================
sub trace_error {
#===================================
    my ( $self, $error, $time ) = @_;
    my $tracer = $self->{tracer} or return;
    my $var    = $self->serializer->decode( $error->{vars}{body} );
    my $body   = $self->serializer->encode_pretty($var);
    $body =~ s/^/# /mg if defined $body;

    my $msg = sprintf(
        "# [%s] ERROR: %s\n%s\n",
        scalar localtime($time),
        $error->{text}, ( $body || '' )
    );
    $tracer->trace($msg);
}

#===================================
sub trace_comment {
#===================================
    my ( $self, $comment ) = @_;
    my $tracer = $self->{tracer} or return;
    $comment =~ s/^/# /mg;
    $tracer->trace($comment);

}

1;
