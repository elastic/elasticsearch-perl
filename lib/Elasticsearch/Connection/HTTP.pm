package Elasticsearch::Connection::HTTP;

use strict;
use warnings;
use namespace::autoclean;
use URI;
use parent 'Elasticsearch::Connection';

my $CRLF = "\015\012";

#===================================
sub protocol     {'http'}
sub default_port {9200}
#===================================

#===================================
sub new {
#===================================
    my $self = shift()->SUPER::new(@_);

    if ( $self->auth ) {

        require MIME::Base64;
        my $auth = MIME::Base64::encode_base64( $self->auth );
        $self->{default_headers}{Authorization} = "Basic $auth";

        $self->{ping_request}
            = "GET / HTTP/1.1"
            . $CRLF
            . "Authorization: Basic $auth"
            . $CRLF
            . $CRLF;
    }
    else {
        $self->{ping_request} = "GET / HTTP/1.1" . $CRLF . $CRLF;
    }

    if ( $self->deflate ) {
        $self->{default_headers}{'Accept-Encoding'} = 'deflate';
    }

    return $self;

}

#===================================
sub default_args {
#===================================
    return (
        default_headers => {},
        deflate         => 0,
        https           => '',
        auth            => ''
    );
}

#===================================
sub http_uri {
#===================================
    my ( $self, $node, $path, $qs ) = @_;
    my $protocol = $self->https ? 'https' : 'http';
    my $uri = URI->new( $protocol . '://' . $node . $path );
    $uri->query_form($qs);
    return $uri;
}

#===================================
sub open_socket {
#===================================
    my ( $self, $node ) = @_;
    if ( $self->https ) {
        require IO::Socket::SSL;
        return IO::Socket::SSL->new(
            PeerAddr        => $node,
            Proto           => 'tcp',
            Blocking        => 0,
            SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE(),
        );
    }
    return $self->SUPER::open_socket($node);
}

#===================================
sub deflate         { $_[0]->{deflate} }
sub https           { $_[0]->{https} }
sub default_headers { $_[0]->{default_headers} }
sub auth            { $_[0]->{auth} }
sub ping_response   {"HTTP/1.1 200 OK"}
#===================================

1;
