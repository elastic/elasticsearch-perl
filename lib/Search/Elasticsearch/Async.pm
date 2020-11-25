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

package Search::Elasticsearch::Async;

our $VERSION = '7.100_1';
use Search::Elasticsearch 7.00;
use Promises 0.93 ();
use parent 'Search::Elasticsearch';

use Search::Elasticsearch::Util qw(parse_params);
use namespace::clean;


#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $self = $class->SUPER::new(
        {   cxn_pool  => 'Async::Static',
            transport => 'Async',
            cxn       => 'AEHTTP',
            %$params
        }
    );
    unless ( $self->bulk_helper_class ) {
        $self->bulk_helper_class(
            'Client::' . $self->api_version . '::Async::Bulk' );
    }
    unless ( $self->scroll_helper_class ) {
        $self->scroll_helper_class(
            'Client::' . $self->api_version . '::Async::Scroll' );
    }
    return $self;
}

1;

# ABSTRACT: Async API for Elasticsearch using Promises

__END__

=head1 SYNOPSIS

    use Search::Elasticsearch::Async;
    use Promises backend => ['AnyEvent'];

    # Connect to localhost:9200:

    my $e = Search::Elasticsearch::Async->new();

    # Round-robin between two nodes:

    my $e = Search::Elasticsearch::Async->new(
        nodes => [
            'search1:9200',
            'search2:9200'
        ]
    );

    # Connect to cluster at search1:9200, sniff all nodes and round-robin between them:

    my $e = Search::Elasticsearch::Async->new(
        nodes    => 'search1:9200',
        cxn_pool => 'Async::Sniff'
    );

    # Index a document:

    $e->index(
        index   => 'my_app',
        type    => 'blog_post',
        id      => 1,
        body    => {
            title   => 'Elasticsearch clients',
            content => 'Interesting content...',
            date    => '2013-09-24'
        }
    )->then( sub { my $result = shift; do_something($result) } );

    # Get the document:

    my $doc;
    $e->get(
        index   => 'my_app',
        type    => 'blog_post',
        id      => 1
    )->then( sub { $doc = shift });

    # Search:

    my $results;
    $e->search(
        index => 'my_app',
        body  => {
            query => {
                match => { title => 'elasticsearch' }
            }
        }
    )->then( sub { $results = shift });

    # Cluster requests:

    $e->cluster->info      ->then( sub { do_something(@_) });
    $e->cluster->health    ->then( sub { do_something(@_) });
    $e->cluster->node_stats->then( sub { do_something(@_) });

    # Index requests:

    $e->indices->create(index=>'my_index')->then( sub { do_something(@_) });
    $e->indices->delete(index=>'my_index')->then( sub { do_something(@_) });

=head1 DESCRIPTION

L<Search::Elasticsearch::Async> is the official B<asynchronous> Perl client for
Elasticsearch, supported by L<elastic.co|http://elastic.co>.
Elasticsearch itself is a flexible and powerful open source, distributed real-time
search and analytics engine for the cloud.  You can read more about it
on L<elastic.co|http://www.elastic.co>.

This module uses L<Promises> to provide a sane async interface, making your
async code look more like synchronous code.  It can be used with
L<Mojolicious> or with any of the event loops supported by L<AnyEvent>.

L<Search::Elasticsearch::Async> builds on L<Search::Elasticsearch>, which
you should see for the main documentation.

=head1 PREVIOUS VERSIONS OF ELASTICSEARCH

This version of the async client supports the Elasticsearch 5.0 branch,
which is not backwards compatible with earlier branches.

If you need to talk to a version of Elasticsearch before 5.0.0, please
install one of the following packages:

=over

=item *

L<Search::Elasticsearch::Client::2_0::Async>

=item *

L<Search::Elasticsearch::Client::1_0::Async>

=item *

L<Search::Elasticsearch::Client::0_90::Async>

=back

=head1 USING PROMISES

First, go and read L<Promises::Cookbook::GentleIntro>, which tells you
everything you need to know about working with L<Promises>.  Using them
with L<Search::Elasticsearch::Async> is easy:

=head2 Choose a Promises backend

The Promises module does not use an event loop by default. You need to specify
the one to use at the start of your application.  Typically, you will be using
the L<EV> event loop (which both AnyEvent and Mojo prefer), in which case you
need:

    use Promises backend => ['EV'];

Otherwise you can specify the C<Mojo> or C<AnyEvent> backends.

=head2 Instantiate the client

    use Search::Elasticsearch::Async;
    my $es = Search::Elasticsearch::Async->new( %params );

See L</"CREATING A NEW INSTANCE"> for an explantion of C<%params>.

=head2 Make a request

    my $promise = $es->search;

All requests to Elasticsearch return a L<Promise> object, which is a value
that will be resolved later on.  You can call C<then()> on the C<$promise>
to specify a success callback and an error callback:

    $promise->then(
        sub { my $result = shift; do_something() },  # success callback
        sub { my $error  = shift; warn $error    }   # error callback
    );

So far, so much like L<AnyEvent/CONDITION VARIABLES>... but
C<then()> returns another C<$promise>, which makes them chainable:

    $promise->then(sub  { print "Got a result"; return @_ })
            ->then(sub  { my $result = shift; something_async($result) })
            ->then(sub  { my $next_result = shift; ...etc...})
            ->catch(sub { warn "Something failed: @_"});

See L<Promises::Cookbook::GentleIntro> for a full explanation of
what you can do with Promises.

=head2 Start the event loop

Async requests are run by the event loop, so no promises will be resolved
or rejected until the event loop is started.  In a fully async application,
you would start the event loop once and just let it run until the application
exits. For instance, here's a simple example which reads search keywords
from STDIN, performs an async search and prints the results. This process
is repeated until the application is interrupted with C<Ctrl-C>.:

    use v5.12;
    use AnyEvent;
    use Search::Elasticsearch::Async;

    # EV must be installed
    use Promises (backend => ['EV'], 'deferred');

    my $es = Search::Elasticsearch::Async->new;

    main();

    say "Starting";

    # start the event loop
    EV::run;

    sub main {
        read_input()
            ->then( \&do_search )
            ->then( \&print_results )

            # warn if either of the above steps throws an error
            ->catch( sub { warn "Something went wrong: @_"; } )

            # regardless of success or failure, run main() again
            ->finally( \&main );
    }

    sub read_input {
        say "Enter search keywords:";

        # We wrap AnyEvent so that it returns a promise
        # which is resolved when we have read from STDIN
        my $d = deferred;

        my $w;
        $w = AnyEvent->io(
            fh   => \*STDIN,
            poll => 'r',
            cb   => sub {
                chomp( my $input = <STDIN> );
                undef $w;

                # resolve the promise
                $d->resolve($input);
            }
        );

        # return a promise
        return $d->promise;
    }

    sub do_search {
        my $keywords = shift();
        # returns a promise
        $es->search(
            index => 'myindex',
            body  => {
                query => {
                    match => {
                        title => $keywords
                    }
                }
            }
        );
    }

    sub print_results {
        my $results = shift;
        my $total   = $results->{hits}{total};

        unless ($total) {
            say "No results found";
            return;
        }

        say "$total results found";
        my $i = 1;
        for ( @{ $results->{hits}{hits} } ) {
            say $i++ . ': ' . $_->{_source}{title};
        }
    }

=head1 CREATING A NEW INSTANCE

The L</new()> method returns a new L<client|Search::Elasticsearch::Client::6_0::Direct>
which can be used to run requests against the Elasticsearch cluster.

    use Search::Elasticsearch::Async;
    my $e = Search::Elasticsearch::Async->new( %params );

The most important arguments to L</new()> are the following:

=head2 C<nodes>

The C<nodes> parameter tells the client which Elasticsearch nodes it should
talk to.  It can be a single node, multiples nodes or, if not
specified, will default to C<localhost:9200>:

    # default: localhost:9200
    $e = Search::Elasticsearch::Async->new();

    # single
    $e = Search::Elasticsearch::Async->new( nodes => 'search_1:9200');

    # multiple
    $e = Search::Elasticsearch::Async->new(
        nodes => [
            'search_1:9200',
            'search_2:9200'
        ]
    );

Each C<node> can be a URL including a scheme, host, port, path and userinfo
(for authentication).  For instance, this would be a valid node:

    https://username:password@search.domain.com:443/prefix/path

See L<Search::Elasticsearch::Role::Cxn/node> for more on node specification.

=head2 C<cxn_pool>

The L<CxnPool|Search::Elasticsearch::Role::CxnPool> modules manage connections to
nodes in the Elasticsearch cluster.  They handle the load balancing between
nodes and failover when nodes fail. Which C<CxnPool> you should use depends on
where your cluster is. There are three choices:

=over

=item * C<Async::Static>

    $e = Search::Elasticsearch::Async->new(
        cxn_pool => 'Async::Static'     # default
        nodes    => [
            'search1.domain.com:9200',
            'search2.domain.com:9200'
        ],
    );

The L<Async::Static|Search::Elasticsearch::CxnPool::Async::Static> connection pool,
which is the default, should be used when you don't have direct access to the
Elasticsearch cluster, eg when you are accessing the cluster through a proxy.  See
L<Search::Elasticsearch::CxnPool::Async::Static> for more.

=item * C<Async::Sniff>

    $e = Search::Elasticsearch::Async->new(
        cxn_pool => 'Async::Sniff',
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

The L<Async::Sniff|Search::Elasticsearch::CxnPool::Async::Sniff> connection pool should be used
when you B<do> have direct access to the Elasticsearch cluster, eg when
your web servers and Elasticsearch servers are on the same network.
The nodes that you specify are used to I<discover> the cluster, which is
then I<sniffed> to find the current list of live nodes that the cluster
knows about. See L<Search::Elasticsearch::CxnPool::Async::Sniff>.

=item * C<Async::Static::NoPing>

    $e = Search::Elasticsearch::Async->new(
        cxn_pool => 'Async::Static::NoPing'
        nodes    => [
            'proxy1.domain.com:80',
            'proxy2.domain.com:80'
        ],
    );

The L<Async::Static::NoPing|Search::Elasticsearch::CxnPool::Async::Static::NoPing> connection
pool should be used when your access to a remote cluster is so limited
that you cannot ping individual nodes with a C<HEAD /> request.

See L<Search::Elasticsearch::CxnPool::Async::Static::NoPing> for more.

=back

=head2 C<trace_to>

For debugging purposes, it is useful to be able to dump the actual HTTP
requests which are sent to the cluster, and the response that is received.
This can be enabled with the C<trace_to> parameter, as follows:

    # To STDERR
    $e = Search::Elasticsearch::Async->new(
        trace_to => 'Stderr'
    );

    # To a file
    $e = Search::Elasticsearch::Async->new(
        trace_to => ['File','/path/to/filename']
    );

Logging is handled by L<Log::Any>.  See L<Search::Elasticsearch::Logger::LogAny>
for more information.

=head2 Other

Other arguments are explained in the respective L<module docs|/MODULES>.

=head1 RUNNING REQUESTS

When you create a new instance of Search::Elasticsearch::Async, it returns a
L<client|Search::Elasticsearch::Client::6_0::Direct> object, which can be used for
running requests.

    use Search::Elasticsearch::Async;
    my $e = Search::Elasticsearch::Async->new( %params );

    # create an index
    $e->indices->create( index => 'my_index' )

    ->then(sub {

        # index a document
        $e->index(
            index   => 'my_index',
            type    => 'blog_post',
            id      => 1,
            body    => {
                title   => 'Elasticsearch clients',
                content => 'Interesting content...',
                date    => '2013-09-24'
            }
        );
    });

See L<Search::Elasticsearch::Client::6_0::Direct> for more details about the requests
that can be run.

=head1 MODULES

Each chunk of functionality is handled by a different module,
which can be specified in the call to L<new()> as shown in L<cxn_pool> above.
For instance, the following will use the L<Search::Elasticsearch::CxnPool::Async::Sniff>
module for the connection pool.

    $e = Search::Elasticsearch::Async->new(
        cxn_pool => 'Async::Sniff'
    );

Custom modules can be named with the appropriate prefix,
eg C<Search::Elasticsearch::CxnPool::>, or by prefixing the full class name
with C<+>:

    $e = Search::Elasticsearch::Async->new(
        cxn_pool => '+My::Custom::CxnClass'
    );

The modules that you can override are specified with the following
arguments to L</new()>:

=head2 C<client>

The class to use for the client functionality, which provides
methods that can be called to execute requests, such as
C<search()>, C<index()> or C<delete()>. The client parses the user's
requests and passes them to the L</transport> class to be executed.

The default version of the client is C<6_0::Direct>, which can
be explicitly specified as follows:

    $e = Search::Elasticsearch::Async->new(
        client => '6_0::Direct'
    );

See :

=over

=item * L<Search::Elasticsearch::Client::6_0::Direct> (default, for 6.0 branch)

=item * L<Search::Elasticsearch::Client::5_0::Direct> (for 5.0 branch)

=item * L<Search::Elasticsearch::Client::2_0::Direct> (for 2.0 branch)

=item * L<Search::Elasticsearch::Client::1_0::Direct> (for 1.0 branch)

=item * L<Search::Elasticsearch::Client::0_90::Direct> (for 0.90 branch)

=back

=head2 C<transport>

The Transport class accepts a parsed request from the L</client> class,
fetches a L</cxn> from its L</cxn_pool> and tries to execute the request,
retrying after failure where appropriate. See:

=over

=item * L<Search::Elasticsearch::Async::Transport>

=back

=head2 C<cxn>

The class which handles raw requests to Elasticsearch nodes.
See:

=over

=item * L<Search::Elasticsearch::Cxn::AEHTTP> (default)

=item * L<Search::Elasticsearch::Cxn::Mojo>

=back

=head2 C<cxn_factory>

The class which the L</cxn_pool> uses to create new L</cxn> objects.
See:

=over

=item * L<Search::Elasticsearch::Cxn::Factory>

=back

=head2 C<cxn_pool> (2)

The class to use for the L<connection pool|/cxn_pool> functionality.
It calls the L</cxn_factory> class to create new L</cxn> objects when
appropriate. See:

=over

=item * L<Search::Elasticsearch::CxnPool::Async::Static> (default)

=item * L<Search::Elasticsearch::CxnPool::Async::Sniff>

=item * L<Search::Elasticsearch::CxnPool::Async::Static::NoPing>

=back

=head2 C<logger>

The class to use for logging events and tracing HTTP requests/responses.  See:

=over

=item * L<Search::Elasticsearch::Logger::LogAny>

=back

=head2 C<serializer>

The class to use for serializing request bodies and deserializing response
bodies.  See:

=over

=item * L<Search::Elasticsearch::Serializer::JSON> (default)

=item * L<Search::Elasticsearch::Serializer::JSON::Cpanel>

=item * L<Search::Elasticsearch::Serializer::JSON::XS>

=item * L<Search::Elasticsearch::Serializer::JSON::PP>

=back

=head1 HELPER MODULES

L<Search::Elasticsearch::Client::6_0::Async::Bulk> and L<Search::Elasticsearch::Client::6_0::Async::Scroll>
are helper modules which assist with bulk indexing and scrolled searching, eg:

    $es->scroll_helper(
        index     => 'myindex',
        on_result => sub { my $doc = shift; do_something($doc) }
    )->then( sub { say "Done!" });

=head1 BUGS

This is a stable API but this implementation is new. Watch this space
for new releases.

If you have any suggestions for improvements, or find any bugs, please report
them to L<http://github.com/elasticsearch/elasticsearch-perl/issues>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Search::Elasticsearch::Async

You can also look for information at:

=over 4

=item * GitHub

L<http://github.com/elasticsearch/elasticsearch-perl>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Search::Elasticsearch::Async>


=item * Search MetaCPAN

L<https://metacpan.org/module/Search::Elasticsearch::Async>

=item * IRC

The L<#elasticsearch|irc://irc.freenode.net/elasticsearch> channel on
C<irc.freenode.net>.

=item * Mailing list

The main L<Elasticsearch mailing list|http://discuss.elastic.co>.

=back

=head1 TEST SUITE

The full test suite requires a live Elasticsearch node to run, and should
be run as :

    perl Makefile.PL
    ES=localhost:9200 make test

B<TESTS RUN IN THIS WAY ARE DESTRUCTIVE! DO NOT RUN AGAINST A CLUSTER WITH
DATA YOU WANT TO KEEP!>
