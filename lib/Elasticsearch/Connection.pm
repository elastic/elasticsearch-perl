package Elasticsearch::Connection;

use strict;
use warnings;
use namespace::autoclean;
use Elasticsearch::Util qw(parse_params init_instance);
use URI;

#===================================
sub protocol     {'http'}
sub default_port {9200}
#===================================

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);

    my $self = bless {
        deflate       => 0,
        path_prefix   => '',
        https         => 0,
        headers       => {},
        handle_params => {},
        mime_type     => $params->{serializer}->mime_type,
        timeout       => 30,
    }, $class;

    init_instance( $self, [], $params );
    $self->{path_prefix} =~ s{/$}{};

    if ( $params->{auth} ) {
        require MIME::Base64;
        my $auth = MIME::Base64::encode_base64( $params->{auth} );
        $self->{headers}{Authorization} = "Basic $auth";
    }
    if ( $self->deflate ) {
        $self->{headers}{'Accept-Encoding'} = 'deflate';
    }

    return $self;

}

#===================================
sub perform_request { throw( "Internal", "Must be overridden in subclass" ) }
sub handle          { throw( "Internal", "Must be overridden in subclass" ) }
sub handle_params   { $_[0]->{handle_params} }
sub mime_type       { $_[0]->{mime_type} }
sub deflate         { $_[0]->{deflate} }
sub path_prefix     { $_[0]->{path_prefix} }
sub https           { $_[0]->{https} }
sub default_headers { $_[0]->{headers} }
sub timeout         { $_[0]->{timeout} }
#===================================

#===================================
sub inflate {
#===================================
    my $self    = shift;
    my $content = shift;

    my $output;
    require IO::Uncompress::Inflate;
    no warnings 'once';

    IO::Uncompress::Inflate::inflate( \$content, \$output, Transparent => 0 )
        or throw( 'Request',
        "Couldn't inflate response: $IO::Uncompress::Inflate::InflateError" );

    return $output;
}

#===================================
sub http_uri {
#===================================
    my ( $self, $node, $path, $qs ) = @_;
    my $protocol = $self->https ? 'https' : 'http';
    $path = $self->path_prefix . $path;
    my $uri = URI->new( $protocol . '://' . $node . $path );
    $uri->query_form($qs);
    return $uri;
}

1;
