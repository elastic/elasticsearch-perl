# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

package Search::Elasticsearch::Transport::Async;

use Moo;
with 'Search::Elasticsearch::Role::Is_Async',
    'Search::Elasticsearch::Role::Transport';

use Time::HiRes qw(time);
use Search::Elasticsearch::Util qw(upgrade_error);
use Promises qw(deferred);
use namespace::clean;

#===================================
sub perform_request {
#===================================
    my $self   = shift;
    my $params = $self->tidy_request(@_);
    my $pool   = $self->cxn_pool;
    my $logger = $self->logger;

    my $deferred = deferred;

    my ( $start, $cxn );
    $pool->next_cxn

        # perform request
        ->then(
        sub {
            $cxn   = shift;
            $start = time();
            $cxn->perform_request($params);
        }
        )

        # log request regardless of success/failure
        ->finally( sub { $logger->trace_request( $cxn, $params ) } )

        ->done(
        # request succeeded
        sub {
            my ( $code, $response ) = @_;
            $pool->request_ok($cxn);
            $logger->trace_response( $cxn, $code, $response,
                time() - $start );
            $deferred->resolve($response);
        },

        # request failed
        sub {
            my $error = upgrade_error( shift(), { request => $params } );
            if ( $pool->request_failed( $cxn, $error ) ) {

                # log failed, then retry
                $logger->debugf( "[%s] %s", $cxn->stringify, "$error" );
                $logger->info('Retrying request on a new cxn');
                return $self->perform_request($params)->done(
                    sub { $deferred->resolve(@_) },
                    sub { $deferred->reject(@_) }
                );
            }
            if ($cxn) {
                $logger->trace_request( $cxn, $params );
                $logger->trace_error( $cxn, $error );
            }
            $error->is('NoNodes')
                ? $logger->critical($error)
                : $logger->error($error);
            $deferred->reject($error);
        }
        );
    return $deferred->promise;
}

1;

#ABSTRACT: Provides async interface between the client class and the Elasticsearch cluster

=head1 DESCRIPTION

The Async::Transport class manages the request cycle. It receives parsed requests
from the (user-facing) client class, and tries to execute the request on a
node in the cluster, retrying a request if necessary.

This class does L<Search::Elasticsearch::Role::Transport> and
L<Search::Elasticsearch::Role::Is_Async>.

=head1 CONFIGURATION

=head2 C<send_get_body_as>

    $e = Search::Elasticsearch::Async->new(
        send_get_body_as => 'POST'
    );

Certain endpoints like L<Search::Elasticsearch::Client::6_0::Direct/search()>
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

    $promise = $e->transport->perform_request(
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

C<perform_request()> returns a L<Promise> object, which will be resolved
(success) or rejected (error) at some point in the future.

Other than the C<method>, C<path>, C<qs> and C<body> parameters, which
should be self-explanatory, it also accepts:

=over

=item C<ignore>

The HTTP error codes which should be ignored instead of throwing an error,
eg C<404 NOT FOUND>:

    $promise = $e->transport->perform_request(
        method => 'GET',
        path   => '/index/type/id'
        ignore => [404],
    );

=item C<serialize>

Whether the C<body> should be serialized in the standard way (as plain
JSON) or using the special I<bulk> format:  C<"std"> or C<"bulk">.

=back

