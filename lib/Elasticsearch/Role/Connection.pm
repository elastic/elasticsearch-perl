package Elasticsearch::Role::Connection;

use Moo::Role;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use IO::Socket();
use URI();

requires qw(protocol default_port handle ping_request valid_ping_response);

has 'max_content_length' => ( is => 'rw' );
has 'timeout' => ( is => 'ro', default => 30 );
has 'handle_params' => (
    is      => 'ro',
    default => sub { +{} }
);

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

my %Code_To_Error = (
    409 => 'Conflict',
    404 => 'Missing',
    403 => 'ClusterBlocked',
    503 => 'NotReady'
);

#===================================
sub code_to_error { $Code_To_Error{ $_[1] || '' } }
#===================================


1;
