package Elasticsearch::Role::Cxn::HTTP;

use Moo::Role;
with 'Elasticsearch::Role::Cxn';
use URI();
use Elasticsearch::Util qw(parse_params);
use namespace::autoclean;

has 'scheme'             => ( is => 'ro' );
has 'is_https'           => ( is => 'ro' );
has 'userinfo'           => ( is => 'ro' );
has 'max_content_length' => ( is => 'ro' );
has 'default_headers'    => ( is => 'ro' );
has 'handle'             => ( is => 'lazy' );

#===================================
sub protocol     {'http'}
sub default_host {'http://localhost:9200'}
sub stringify    { shift->uri . '' }
#===================================

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);

    my $node = $params->{node}
        || { host => 'localhost', port => '9200' };

    unless ( ref $node eq 'HASH' ) {
        unless ( $node =~ m{^http(s)?://} ) {
            $node = ( $params->{https} ? 'https://' : 'http://' ) . $node;
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

    my $host = $node->{host} || 'localhost';
    my $userinfo = $node->{userinfo} || $params->{userinfo} || '';
    my $scheme = $node->{scheme} || ( $params->{https} ? 'https' : 'http' );
    my $port   = $node->{port}   || ( $scheme eq 'http' ? 80 : 443 );
    my $path   = $node->{path}   || '';
    $path =~ s{/+$}{};

    my %default_headers = %{ $params->{default_headers} || {} };

    if ($userinfo) {
        require MIME::Base64;
        my $auth = MIME::Base64::encode_base64($userinfo);
        chomp $auth;
        $default_headers{Authorization} = "Basic $auth";
    }

    if ( $params->{deflate} ) {
        $default_headers{'Accept-Encoding'} = "deflate";
    }

    $params->{scheme}          = $scheme;
    $params->{is_http}         = $scheme eq 'https';
    $params->{host}            = $host;
    $params->{port}            = $port;
    $params->{path}            = $path;
    $params->{userinfo}        = $userinfo;
    $params->{uri}             = URI->new("$scheme://$host:$port$path");
    $params->{default_headers} = \%default_headers;

    return $params;

}

#===================================
sub build_uri {
#===================================
    my ( $self, $params ) = @_;
    my $uri = $self->uri->clone;
    $uri->path( $uri->path . $params->{path} );
    $uri->query_form( $params->{qs} );
    return $uri;
}

#===================================
before 'perform_request' => sub {
#===================================
    my ( $self, $params ) = @_;
    return unless defined $params->{data};

    my $max = $self->max_content_length
        or return;

    return if length( $params->{data} ) < $max;

    $self->logger->throw_error( 'ContentLength',
        "Body is longer than max_content_length ($max)",
    );
};

#===================================
around 'process_response' => sub {
#===================================
    my ( $orig, $self, $params, $code, $msg, $body, $encoding ) = @_;

    $body = $self->inflate($body)
        if $encoding && $encoding eq 'deflate';

    $orig->( $self, $params, $code, $msg, $body );
};

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

1;
