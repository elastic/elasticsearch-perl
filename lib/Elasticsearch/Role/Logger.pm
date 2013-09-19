package Elasticsearch::Role::Logger;

use Moo::Role;
use namespace::autoclean;

use URI();
use Try::Tiny;

has 'serializer' => ( is => 'ro', required => 1 );
has 'log_as'     => ( is => 'ro', default  => 'elasticsearch.event' );
has 'trace_as'   => ( is => 'ro', default  => 'elasticsearch.trace' );
has 'log_to'     => ( is => 'ro' );
has 'trace_to'   => ( is => 'ro' );
has 'trace_handle' => (
    is      => 'lazy',
    handles => [qw( trace tracef is_trace)]
);

has 'log_handle' => (
    is      => 'lazy',
    handles => [ qw(
            debug       debugf      is_debug
            info        infof       is_info
            warning     warningf    is_warning
            error       errorf      is_error
            critical    criticalf   is_critical
            )
    ]
);

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
    my ( $self, $cxn, $params ) = @_;
    return unless $self->is_trace;

    my $uri = URI->new( 'http://localhost:9200' . $params->{path} );
    $uri->query_form( { %{ $params->{qs} }, pretty => 1 } );

    my $body
        = $params->{serialize} eq 'std'
        ? $self->serializer->encode_pretty( $params->{body} )
        : $params->{data};

    if ( defined $body ) {
        $body =~ s/'/\\u0027/g;
        $body = " -d '\n$body'\n";
    }
    else { $body = "\n" }

    my $msg = sprintf(
        "# Request to: %s\n"         #
            . "curl -X%s '%s'%s",    #
        $cxn->stringify,
        $params->{method},
        $uri,
        $body
    );

    $self->trace($msg);
}

#===================================
sub trace_response {
#===================================
    my ( $self, $cxn, $code, $response, $took ) = @_;
    return unless $self->is_trace;

    my $body = $self->serializer->encode_pretty($response) || "\n";
    $body =~ s/^/# /mg;

    my $msg = sprintf(
        "# Response: %s, Took: %d ms\n%s",    #
        $code, $took * 1000, $body
    );

    $self->trace($msg);
}

#===================================
sub trace_error {
#===================================
    my ( $self, $cxn, $error ) = @_;
    return unless $self->is_trace;

    my $body
        = $self->serializer->encode_pretty( $error->{vars}{body} || "\n" );
    $body =~ s/^/# /mg;

    my $msg
        = sprintf( "# ERROR: %s %s\n%s", ref($error), $error->{text}, $body );

    $self->trace($msg);
}

#===================================
sub trace_comment {
#===================================
    my ( $self, $comment ) = @_;
    return unless $self->is_trace;
    $comment =~ s/^/# *** /mg;
    chomp $comment;
    $self->trace("$comment\n");
}

1;
