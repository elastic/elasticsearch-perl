package Search::Elasticsearch::Cxn::Mojo;

use Mojo::UserAgent();
use Promises qw(deferred);
use Try::Tiny;
use Moo;

with 'Search::Elasticsearch::Role::Cxn::Async';
with 'Search::Elasticsearch::Role::Cxn::HTTP',
    'Search::Elasticsearch::Role::Cxn',
    'Search::Elasticsearch::Role::Is_Async';

# connect timeout

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
    my $handle   = $self->handle;
    $handle->request_timeout( $params->{timeout} || $self->request_timeout );

    $handle->build_tx(
        $method => $uri,
        \%headers,
        $data,
        sub {
            my ( $ua, $tx ) = @_;
            my $res     = $tx->res;
            my $headers = $res->headers->to_hash;
            $headers->{ lc($_) } = delete $headers->{$_} for keys %{$headers};
            try {
                my ( $code, $response ) = $self->process_response(
                    $params,        # request
                    $res->code,     # status
                    $res->error,    # reason
                    $res->body,     # content
                    $headers,       # headers
                );
                $deferred->resolve( $code, $response );
            }
            catch {
                $deferred->reject($_);
            };
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

#===================================
sub _build_handle { Mojo::UserAgent->new }
#===================================

1;
