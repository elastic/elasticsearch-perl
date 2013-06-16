package Elasticsearch::Logger;

use strict;
use warnings;
use Elasticsearch::Util qw(parse_params init_instance);
use namespace::autoclean;
use Log::Any();
use Elasticsearch::Util qw(parse_params init_instance);
use URI();

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $self = bless {}, $class;

    init_instance( $self, ['serializer'], $params );

    if ( my $args = $params->{logger} ) {
        $args = [$args] unless ref $args eq 'ARRAY';
        Log::Any::Adapter->set( { category => 'elasticsearch' }, @$args );
    }
    $self->{logger} = Log::Any->get_logger( category => 'elasticsearch' );

    if ( my $args = $params->{tracer} ) {
        $args = [$args] unless ref $args eq 'ARRAY';
        Log::Any::Adapter->set( { category => 'elasticsearch.trace' },
            @$args );
        $self->{tracer}
            = Log::Any->get_logger( category => 'elasticsearch.trace' );
    }
    return $self;
}

#===================================
sub debug     { shift->{logger}->debug(@_) }
sub debugf    { shift->{logger}->debugf(@_) }
sub info      { shift->{logger}->info(@_) }
sub infof     { shift->{logger}->infof(@_) }
sub warn      { shift->{logger}->warn(@_) }
sub warnf     { shift->{logger}->warnf(@_) }
sub error     { shift->{logger}->error(@_) }
sub errorf    { shift->{logger}->errorf(@_) }
sub critical  { shift->{logger}->critical(@_) }
sub criticalf { shift->{logger}->criticalf(@_) }
sub is_debug  { shift->{logger}->is_debug }
sub is_info   { shift->{logger}->is_debug }
#===================================

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
        $error->{text}, $body
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

#===================================
sub serializer { $_[0]->{serializer} }
#===================================

1;
