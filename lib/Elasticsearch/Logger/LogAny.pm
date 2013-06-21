package Elasticsearch::Logger::LogAny;

use Moo;
use namespace::autoclean;
use Log::Any();
use Log::Any::Adapter();
use URI();

with 'Elasticsearch::Role::Logger';

#===================================
sub BUILDARGS {
#===================================
    my $class = shift;
    my %params = ref $_[0] ? %{ shift() } : @_;
    if ( my $args = delete $params{log_to} ) {
        $args = [$args] unless ref $args eq 'ARRAY';
        Log::Any::Adapter->set( { category => 'elasticsearch' }, @$args );
    }
    $params{log_to} = Log::Any->get_logger( category => 'elasticsearch' );

    if ( my $args = $params{trace_to} ) {
        $args = [$args] unless ref $args eq 'ARRAY';
        Log::Any::Adapter->set( { category => 'elasticsearch.trace' },
            @$args );
        $params{trace_to}
            = Log::Any->get_logger( category => 'elasticsearch.trace' );
    }
    return \%params;
}

#===================================
sub trace_request {
#===================================
    my ( $self, $node, $request, $time ) = @_;
    my $tracer = $self->trace_to or return;

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
    my $tracer = $self->trace_to or return;

    my $body = $self->serializer->encode_pretty($response)
        || '<NO BODY>';    ## log 200/404 for exists?
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
    my $tracer = $self->trace_to or return;
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
    my $tracer = $self->trace_to or return;
    $comment =~ s/^/# /mg;
    $tracer->trace($comment);

}

#===================================
sub debug     { shift->log_to->debug(@_) }
sub debugf    { shift->log_to->debugf(@_) }
sub info      { shift->log_to->info(@_) }
sub infof     { shift->log_to->infof(@_) }
sub warn      { shift->log_to->warn(@_) }
sub warnf     { shift->log_to->warnf(@_) }
sub error     { shift->log_to->error(@_) }
sub errorf    { shift->log_to->errorf(@_) }
sub critical  { shift->log_to->critical(@_) }
sub criticalf { shift->log_to->criticalf(@_) }
sub is_debug  { shift->log_to->is_debug(@_) }
sub is_info   { shift->log_to->is_info(@_) }
#===================================

1;
