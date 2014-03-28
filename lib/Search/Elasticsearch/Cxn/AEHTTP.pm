package Search::Elasticsearch::Cxn::AEHTTP;

use AnyEvent::HTTP qw(http_request);
use Promises qw(deferred);
use Try::Tiny;
use Moo;

with 'Search::Elasticsearch::Role::Cxn::Async';
with 'Search::Elasticsearch::Role::Cxn::HTTP',
    'Search::Elasticsearch::Role::Cxn',
    'Search::Elasticsearch::Role::Is_Async';

use namespace::clean;

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri     = $self->build_uri($params);
    my $method  = $params->{method};
    my %headers = ( %{ $self->default_headers } );
    my $data    = $params->{data};
    if ( defined $data ) {
        $headers{'Content-Type'} = $params->{mime_type};
    }

    my $deferred = deferred;

    http_request(
        $method => $uri,
        headers => \%headers,
        timeout => $params->{timeout} || $self->request_timeout,
        body => $data,
        persistent => 0,
        sub {
            my ( $body, $headers ) = @_;
            try {
                my ( $code, $response ) = $self->process_response(
                    $params,                      # request
                    delete $headers->{Status},    # code
                    delete $headers->{Reason},    # msg
                    $body,                        # body
                    $headers                      # headers
                );
                $deferred->resolve( $code, $response );
            }
            catch {
                $deferred->reject($_);
            }

        }
    );
    $deferred->promise;
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];
    return
          /[Tt]imed out/     ? 'Timeout'
        : /Invalid argument/ ? 'Cxn'
        :                      'Request';
}

1;
