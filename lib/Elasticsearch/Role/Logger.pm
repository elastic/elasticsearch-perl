package Elasticsearch::Role::Logger;

use Moo::Role;
use namespace::autoclean;

use Try::Tiny;

has 'serializer' => ( is => 'ro', required => 1 );
has 'trace_to'   => ( is => 'ro' );
has 'log_to'     => ( is => 'ro' );

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
    return unless $self->is_trace;

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

    $self->trace($msg);
}

#===================================
sub trace_response {
#===================================
    my ( $self, $node, $response, $time, $took ) = @_;
    return unless $self->is_trace;

    my $body = $self->serializer->encode_pretty($response)
        || '<NO BODY>';    ## log 200/404 for exists?
    $body =~ s/^/# /mg;

    my $msg = sprintf(
        "# [%s] Took:%dms\n%s",
        scalar localtime($time),
        $took * 1000, $body
    );

    $self->trace($msg);
}

#===================================
sub trace_error {
#===================================
    my ( $self, $error, $time ) = @_;
    return unless $self->is_trace;
    my $body;
    try {
        my $var = $self->serializer->decode( $error->{vars}{body} );
        $body = $self->serializer->encode_pretty($var);
    }
    catch {
        $body = $error->{vars}{body};
    };

    $body =~ s/^/# /mg if defined $body;

    my $msg = sprintf(
        "# [%s] ERROR: %s\n%s\n",
        scalar localtime($time),
        $error->{text}, ( $body || '' )
    );
    $self->trace($msg);
}

#===================================
sub trace_comment {
#===================================
    my ( $self, $comment ) = @_;
    return unless $self->is_trace;
    my $tracer = $self->trace_to or return;
    $comment =~ s/^/# /mg;
    $self->trace($comment);
}

#===================================
sub debug       { ( shift->log_to   || return )->debug(@_) }
sub debugf      { ( shift->log_to   || return )->debugf(@_) }
sub info        { ( shift->log_to   || return )->info(@_) }
sub infof       { ( shift->log_to   || return )->infof(@_) }
sub warn        { ( shift->log_to   || return )->warn(@_) }
sub warnf       { ( shift->log_to   || return )->warnf(@_) }
sub error       { ( shift->log_to   || return )->error(@_) }
sub errorf      { ( shift->log_to   || return )->errorf(@_) }
sub critical    { ( shift->log_to   || return )->critical(@_) }
sub trace       { ( shift->trace_to || return )->trace(@_) }
sub tracef      { ( shift->trace_to || return )->tracef(@_) }
sub is_debug    { ( shift->log_to   || return )->is_debug(@_) }
sub is_info     { ( shift->log_to   || return )->is_info(@_) }
sub is_warn     { ( shift->log_to   || return )->is_warn(@_) }
sub is_error    { ( shift->log_to   || return )->is_error(@_) }
sub is_critical { ( shift->log_to   || return )->is_critical(@_) }
sub is_trace    { ( shift->trace_to || return )->is_trace(@_) }
#===================================

1;
