package Elasticsearch::Role::Connection::HTTP;

use Moo::Role;
with 'Elasticsearch::Role::Connection';
use namespace::autoclean;
use URI();

my $CRLF = "\015\012";

has 'deflate' => ( is => 'ro' );
has 'https'   => ( is => 'ro' );
has 'auth'    => ( is => 'ro' );
has 'default_headers' => (
    is      => 'ro',
    default => sub { +{} }
);

#===================================
sub protocol             {'http'}
sub default_port         {9200}
sub ping_response_length {15}
#===================================

#===================================
sub BUILD {
#===================================
    my $self = shift;

    if ( $self->auth ) {
        require MIME::Base64;
        my $auth = MIME::Base64::encode_base64( $self->auth );
        chomp $auth;
        $self->default_headers->{Authorization} = "Basic $auth";
    }

    if ( $self->deflate ) {
        $self->default_headers->{'Accept-Encoding'} = 'deflate';
    }

    return $self;

}

#===================================
sub ping_request {
#===================================
    my ( $self, $node ) = @_;
    my ($host) = split /:/, $node;

    my $request = "HEAD / HTTP/1.1" . $CRLF . "Host: $host" . $CRLF;

    if ( $self->auth ) {
        $request
            .= "Authorization: "
            . $self->default_headers->{Authorization}
            . $CRLF;
    }
    return $request . $CRLF;
}

#===================================
sub valid_ping_response {
#===================================
    my ( $self, $response ) = @_;
    return $response =~ m{HTTP/1.1 200 OK};
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
around 'open_socket' => sub {
#===================================
    my $orig = shift;
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
    return $orig->(@_);
};

1;
