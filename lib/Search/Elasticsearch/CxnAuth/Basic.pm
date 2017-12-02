package Search::Elasticsearch::CxnAuth::Basic;

use Moo;
#with 'Search::Elasticsearch::Role::Cxn', 'Search::Elasticsearch::Role::Is_Sync';
use Search::Elasticsearch::Util qw(parse_params);

use namespace::clean;

has authorization_token => (is => 'ro');

sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);

    my $node = $params->{node}
        || { host => 'localhost', port => '9200' };

    unless ( ref $node eq 'HASH' ) {
        unless ( $node =~ m{^http(s)?://} ) {
            $node = ( $params->{use_https} ? 'https://' : 'http://' ) . $node;
        }
        if ( $params->{port} && $node !~ m{//[^/]+:\d+} ) {
            $node =~ s{(//[^/]+)}{$1:$params->{port}};
        }
        my $uri = URI->new($node);
        $node = {
            scheme   => $uri->scheme,
            host     => $uri->host,
            port     => $uri->port,
            path     => $uri->path,
            userinfo => $uri->userinfo
        };
    }

    my $userinfo = $node->{userinfo} || $params->{userinfo} || '';

    if( $userinfo ) {
        require MIME::Base64;
        my $auth = MIME::Base64::encode_base64($userinfo);
        chomp $auth;
        $params->{authorization_token} = $auth;
    }

    return $params;
}

sub default_authentication_headers {
    my ( $self ) = @_;

    return $self->authorization_token ? { Authorization => "Basic ".$self->authorization_token }:{};
}

sub authenticate_request {
    my ($self, $method, $uri, $headers, $content ) = @_;

    #if( $self->authorization_token ) {
        #$headers->{Authorization} = "Basic ".$self->authorization_token;
    #}

    return $uri, $headers;
 }

1;
