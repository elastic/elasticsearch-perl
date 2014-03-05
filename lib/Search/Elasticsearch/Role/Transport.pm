package Search::Elasticsearch::Role::Transport;

use Moo::Role;

requires qw(perform_request);

use Try::Tiny;
use Search::Elasticsearch::Util qw(parse_params is_compat);
use namespace::clean;

has 'serializer'       => ( is => 'ro', required => 1 );
has 'logger'           => ( is => 'ro', required => 1 );
has 'send_get_body_as' => ( is => 'ro', default  => 'GET' );
has 'cxn_pool'         => ( is => 'ro', required => 1 );

#===================================
sub BUILD {
#===================================
    my $self = shift;
    my $pool = $self->cxn_pool;
    is_compat( 'cxn_pool', $self, $pool );
    is_compat( 'cxn',      $self, $pool->cxn_factory->cxn_class );
    return $self;
}

#===================================
sub tidy_request {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $params->{method} ||= 'GET';
    $params->{path}   ||= '/';
    $params->{qs}     ||= {};
    $params->{ignore} ||= [];
    my $body = $params->{body};
    return $params unless defined $body;

    $params->{serialize} ||= 'std';
    $params->{data}
        = $params->{serialize} eq 'std'
        ? $self->serializer->encode($body)
        : $self->serializer->encode_bulk($body);

    if ( $params->{method} eq 'GET' ) {
        my $send_as = $self->send_get_body_as;
        if ( $send_as eq 'POST' ) {
            $params->{method} = 'POST';
        }
        elsif ( $send_as eq 'source' ) {
            $params->{qs}{source} = delete $params->{data};
            delete $params->{body};
        }
    }

    $params->{mime_type} ||= $self->serializer->mime_type;
    return $params;

}

1;

#ABSTRACT: Transport role providing interface between the client class and the Elasticsearch cluster
