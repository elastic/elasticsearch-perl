package Elasticsearch::Transport;

use Moo;

use URI();
use Time::HiRes qw(time);
use Try::Tiny;
use Elasticsearch::Util qw(upgrade_error);
use namespace::clean;

with 'Elasticsearch::Role::Is_Sync', 'Elasticsearch::Role::Transport';

#===================================
sub perform_request {
#===================================
    my $self   = shift;
    my $params = $self->tidy_request(@_);
    my $pool   = $self->cxn_pool;
    my $logger = $self->logger;

    my ( $code, $response, $cxn, $error );

    try {
        $cxn = $pool->next_cxn;
        my $start = time();
        $logger->trace_request( $cxn, $params );

        ( $code, $response ) = $cxn->perform_request($params);
        $pool->request_ok($cxn);
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
    };

    if ($error) {
        if ( $pool->request_failed( $cxn, $error ) ) {
            $logger->debugf( "[%s] %s", $cxn->stringify, "$error" );
            $logger->info('Retrying request on a new cxn');
            return $self->perform_request($params);
        }

        $logger->trace_error( $cxn, $error );
        delete $error->{vars}{body};
        $error->is('NoNodes')
            ? $logger->throw_critical($error)
            : $logger->throw_error($error);
    }

    return $response;
}

1;
