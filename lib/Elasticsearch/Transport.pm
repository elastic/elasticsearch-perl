package Elasticsearch::Transport;

use Moo;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use URI();
use Time::HiRes qw(time);
use Try::Tiny;
use Elasticsearch::Util qw(parse_params);

has 'serializer' => ( is => 'ro', required => 1 );
has 'logger'     => ( is => 'ro', required => 1 );
has 'cxn_pool'   => ( is => 'ro', required => 1 );

#===================================
sub perform_request {
#===================================
    my $self   = shift;
    my $params = $self->tidy_request(@_);
    my $pool   = $self->cxn_pool;
    my $logger = $self->logger;

    my ( $code, $response, $cxn, $retry, $error );

    try {
        $cxn = $pool->next_cxn;
        my $start = time();
        $logger->trace_request( $cxn, $params );

        ( $code, $response ) = $cxn->perform_request($params);
        $cxn->mark_live;
        $logger->trace_response( $cxn, $code, $response, time() - $start );
    }
    catch {
        $error = upgrade_error(
            $_,
            {   request     => $params,
                status_code => $code,
                body        => $response
            }
        );

        if ( $error->is('Cxn') ) {
            $cxn->mark_dead;
            $pool->schedule_check;
            $retry = $self->should_retry( $params, $cxn, $error );
        }
        elsif ( $error->is('Timeout') ) {
            $pool->schedule_check;
        }
        else {
            $cxn->mark_live if $cxn;
        }
    };

    if ($retry) {
        $logger->debugf( "[%s] %s", $cxn->stringify, "$error" );
        $logger->info('Retrying request on a new cxn');
        return $self->perform_request($params);
    }

    $pool->reset_retries;

    if ($error) {
        $logger->trace_error( $cxn, $error );
        delete $error->{vars}{body};
        $error->is('NoNodes')
            ? $logger->throw_critical($error)
            : $logger->throw_error($error);
    }
    return $response;
}

#===================================
sub tidy_request {
#===================================
    my ( $self, $params ) = parse_params(@_);
    $params->{method} ||= 'GET';
    $params->{path}   ||= '/';
    $params->{qs}     ||= {};
    my $body = $params->{body};
    return $params unless defined $body;

    $params->{serialize} ||= 'std';
    $params->{data}
        = $params->{serialize} eq 'std'
        ? $self->serializer->encode($body)
        : $self->serializer->encode_bulk($body);

    return $params;

}

#===================================
sub should_retry {
#===================================
    my ( $self, $request, $cxn, $error ) = @_;
    return $error->is('Cxn');
}

1;

