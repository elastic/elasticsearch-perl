package Search::Elasticsearch::Transport;

use Moo;

use URI();
use Time::HiRes qw(time);
use Try::Tiny;
use Search::Elasticsearch::Util qw(upgrade_error);
use namespace::clean;

with 'Search::Elasticsearch::Role::Is_Sync',
    'Search::Elasticsearch::Role::Transport';

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

#ABSTRACT: Provides interface between the client class and the Elasticsearch cluster

=head1 DESCRIPTION

The Transport class manages the request cycle. It receives parsed requests
from the (user-facing) client class, and tries to execute the request on a
node in the cluster, retrying a request if necessary.

This class does L<Search::Elasticsearch::Role::Transport> and
L<Search::Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 C<send_get_body_as>

    $e = Search::Elasticsearch->new(
        send_get_body_as => 'POST'
    );

Certain endpoints like L<Search::Elasticsearch::Client::Direct/search()>
default to using a C<GET> method, even when they include a request body.
Some proxy servers do not support C<GET> requests with a body.  To work
around this, the C<send_get_body_as>  parameter accepts the following:

=over

=item * C<GET>

The default.  Request bodies are sent as C<GET> requests.

=item * C<POST>

The method is changed to C<POST> when a body is present.

=item * C<source>

The body is encoded as JSON and added to the query string as the C<source>
parameter.  This has the advantage of still being a C<GET> request (for those
filtering on request method) but has the disadvantage of being restricted
in size.  The limit depends on the proxies between the client and
Elasticsearch, but usually is around 4kB.

=back

=head1 METHODS

=head2 C<perform_request()>

Raw requests can be executed using the transport class as follows:

    $result = $e->transport->perform_request(
        method => 'POST',
        path   => '/_search',
        qs     => { from => 0, size => 10 },
        body   => {
            query => {
                match => {
                    title => "Elasticsearch clients"
                }
            }
        }
    );

Other than the C<method>, C<path>, C<qs> and C<body> parameters, which
should be self-explanatory, it also accepts:

=over

=item C<ignore>

The HTTP error codes which should be ignored instead of throwing an error,
eg C<404 NOT FOUND>:

    $result = $e->transport->perform_request(
        method => 'GET',
        path   => '/index/type/id'
        ignore => [404],
    );

=item C<serialize>

Whether the C<body> should be serialized in the standard way (as plain
JSON) or using the special I<bulk> format:  C<"std"> or C<"bulk">.

=back

