package Elasticsearch::Connection;

use strict;
use warnings;
use namespace::autoclean;
use IO::Socket();
use Elasticsearch::Util qw(parse_params init_instance);
use URI;

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %default = $class->default_args;
    my $self    = bless {
        path_prefix   => '',
        handle_params => {},
        mime_type     => $params->{serializer}->mime_type,
        timeout       => 30,
        %default,
    }, $class;

    init_instance( $self, [], $params );
    $self->{path_prefix} =~ s{/$}{};

    return $self;

}

#===================================
sub protocol        { throw( "Internal", "Must be overridden in subclass" ) }
sub default_port    { throw( "Internal", "Must be overridden in subclass" ) }
sub perform_request { throw( "Internal", "Must be overridden in subclass" ) }
sub handle          { throw( "Internal", "Must be overridden in subclass" ) }
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
sub open_socket {
#===================================
    my ( $self, $node ) = @_;
    return IO::Socket::INET->new(
        PeerAddr => $node,
        Proto    => 'tcp',
        Blocking => 0
    );

}

#===================================
sub handle_params { $_[0]->{handle_params} }
sub mime_type     { $_[0]->{mime_type} }
sub deflate       { $_[0]->{deflate} }
sub path_prefix   { $_[0]->{path_prefix} }
sub timeout       { $_[0]->{timeout} }
sub ping_request  { $_[0]->{ping_request} }
sub ping_response { $_[0]->{ping_response} }
sub default_args  { }
#===================================

1;
