package Search::Elasticsearch;

use Moo 1.003 ();

use Search::Elasticsearch::Util qw(parse_params load_plugin);
use namespace::clean;

our $VERSION = '1.19';

my %Default_Plugins = (
    client      => [ 'Search::Elasticsearch::Client',       '1_0::Direct' ],
    cxn_factory => [ 'Search::Elasticsearch::Cxn::Factory', '' ],
    cxn_pool    => [ 'Search::Elasticsearch::CxnPool',      'Static' ],
    logger      => [ 'Search::Elasticsearch::Logger',       'LogAny' ],
    serializer  => [ 'Search::Elasticsearch::Serializer',   'JSON' ],
    transport   => [ 'Search::Elasticsearch::Transport',    '' ],
);

my @Load_Order = qw(
    serializer
    logger
    cxn_factory
    cxn_pool
    transport
    client
);

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);

    $params->{cxn} ||= 'HTTPTiny';
    my $plugins = delete $params->{plugins} || [];

    for my $name (@Load_Order) {
        my ( $base, $default ) = @{ $Default_Plugins{$name} };
        my $sub_class = $params->{$name} || $default;
        my $plugin_class = load_plugin( $base, $sub_class );
        $params->{$name} = $plugin_class->new($params);
    }

    for my $name (@$plugins) {
        my $plugin_class
            = load_plugin( 'Search::Elasticsearch::Plugin', $name );
        $plugin_class->_init_plugin($params);
    }

    return $params->{client};
}

1;

__END__

# ABSTRACT: The official client for Elasticsearch

=head1 SYNOPSIS

    use Search::Elasticsearch;

    # Connect to localhost:9200:

    my $e = Search::Elasticsearch->new();

    # Round-robin between two nodes:

    my $e = Search::Elasticsearch->new(
        nodes => [
            'search1:9200',
            'search2:9200'
        ]
    );

    # Connect to cluster at search1:9200, sniff all nodes and round-robin between them:

    my $e = Search::Elasticsearch->new(
        nodes    => 'search1:9200',
        cxn_pool => 'Sniff'
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
    );

    # Get the document:

    my $doc = $e->get(
        index   => 'my_app',
        type    => 'blog_post',
        id      => 1
    );

    # Search:

    my $results = $e->search(
        index => 'my_app',
        body  => {
            query => {
                match => { title => 'elasticsearch' }
            }
        }
    );

    # Cluster requests:

    $info        = $e->cluster->info;
    $health      = $e->cluster->health;
    $node_stats  = $e->cluster->node_stats

    # Index requests:

    $e->indices->create(index=>'my_index');
    $e->indices->delete(index=>'my_index');

=head1 DESCRIPTION

L<Search::Elasticsearch> is the official Perl client for Elasticsearch,
supported by L<elasticsearch.com|http://www.elasticsearch.com>.  Elasticsearch
itself is a flexible and powerful open source, distributed real-time
search and analytics engine for the cloud.  You can read more about it
on L<elastic.co|http://www.elastic.co>.

=head1 BACKWARDS COMPATIBILITY AND ELASTICSEARCH 0.90.x

This version of the client supports the Elasticsearch 1.0 branch by
default, which is not backwards compatible with the 0.90 branch.

If you need to talk to a version of Elasticsearch before 1.0.0,
please use L<Search::Elasticsearch::Client::0_90::Direct> as follows:

    $es = Search::Elasticsearch->new( client => '0_90::Direct' );


=head2 Motivation

=over

I<The greatest deception men suffer is from their own opinions.>

Leonardo da Vinci

=back

All of us have opinions, especially when it comes to designing APIs.
Unfortunately, the opinions of programmers seldom coincide. The intention of
this client, and of the officially supported clients available for other
languages, is to provide robust support for the full native Elasticsearch API
with as few opinions as possible:  you should be able to read the
L<Elasticsearch reference documentation|http://www.elastic.co/guide>
and understand how to use this client, or any of the other official clients.

Should you decide that you want to customize the API, then this client
provides the basis for your code.  It does the hard stuff for you,
allowing you to build on top of it.

=head2 Features

This client provides:

=over

=item *

Full support for all Elasticsearch APIs

=item *

HTTP backend (for an async backend using L<Promises>, see
L<Search::Elasticsearch::Async>)

=item *

Robust networking support which handles load balancing, failure detection
and failover

=item *

Good defaults

=item *

Helper utilities for more complex operations, such as
L<bulk indexing|Search::Elasticsearch::Bulk>,
L<scrolled searches|Search::Elasticsearch::Scroll> and
L<reindexing|Search::Elasticsearch::Bulk/"reindex()">.

=item *

Logging support via L<Log::Any>

=item *

Compatibility with the official clients for Python, Ruby, PHP and Javascript

=item *

Easy extensibility

=back

=head1 INSTALLING ELASTICSEARCH

You can download the latest version of Elasticsearch from
L<http://www.elastic.co/download>. See the
L<installation instructions|http://www.elastic.co/guide/reference/setup/installation/>
for details. You will need to have a recent version of Java installed,
preferably the Java v7 from Sun.

=head1 CREATING A NEW INSTANCE

The L</new()> method returns a new L<client|Search::Elasticsearch::Client::1_0::Direct>
which can be used to run requests against the Elasticsearch cluster.

    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new( %params );

The most important arguments to L</new()> are the following:

=head2 C<nodes>

The C<nodes> parameter tells the client which Elasticsearch nodes it should
talk to.  It can be a single node, multiples nodes or, if not
specified, will default to C<localhost:9200>:

    # default: localhost:9200
    $e = Search::Elasticsearch->new();

    # single
    $e = Search::Elasticsearch->new( nodes => 'search_1:9200');

    # multiple
    $e = Search::Elasticsearch->new(
        nodes => [
            'search_1:9200',
            'search_2:9200'
        ]
    );

Each C<node> can be a URL including a scheme, host, port, path and userinfo
(for authentication).  For instance, this would be a valid node:

    https://username:password@search.domain.com:443/prefix/path

See L<Search::Elasticsearch::Role::Cxn::HTTP/node> for more on node specification.

=head2 C<cxn_pool>

The L<CxnPool|Search::Elasticsearch::Role::CxnPool> modules manage connections to
nodes in the Elasticsearch cluster.  They handle the load balancing between
nodes and failover when nodes fail. Which C<CxnPool> you should use depends on
where your cluster is. There are three choices:

=over

=item * C<Static>

    $e = Search::Elasticsearch->new(
        cxn_pool => 'Static'     # default
        nodes    => [
            'search1.domain.com:9200',
            'search2.domain.com:9200'
        ],
    );

The L<Static|Search::Elasticsearch::CxnPool::Static> connection pool, which is the
default, should be used when you don't have direct access to the Elasticsearch
cluster, eg when you are accessing the cluster through a proxy.  See
L<Search::Elasticsearch::CxnPool::Static> for more.

=item * C<Sniff>

    $e = Search::Elasticsearch->new(
        cxn_pool => 'Sniff',
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

The L<Sniff|Search::Elasticsearch::CxnPool::Sniff> connection pool should be used
when you B<do> have direct access to the Elasticsearch cluster, eg when
your web servers and Elasticsearch servers are on the same network.
The nodes that you specify are used to I<discover> the cluster, which is
then I<sniffed> to find the current list of live nodes that the cluster
knows about. See L<Search::Elasticsearch::CxnPool::Sniff>.

=item * C<Static::NoPing>

    $e = Search::Elasticsearch->new(
        cxn_pool => 'Static::NoPing'
        nodes    => [
            'proxy1.domain.com:80',
            'proxy2.domain.com:80'
        ],
    );

The L<Static::NoPing|Search::Elasticsearch::CxnPool::Static::NoPing> connection
pool should be used when your access to a remote cluster is so limited
that you cannot ping individual nodes with a C<HEAD /> request.

See L<Search::Elasticsearch::CxnPool::Static::NoPing> for more.

=back

=head2 C<trace_to>

For debugging purposes, it is useful to be able to dump the actual HTTP
requests which are sent to the cluster, and the response that is received.
This can be enabled with the C<trace_to> parameter, as follows:

    # To STDERR
    $e = Search::Elasticsearch->new(
        trace_to => 'Stderr'
    );

    # To a file
    $e = Search::Elasticsearch->new(
        trace_to => ['File','/path/to/filename']
    );

Logging is handled by L<Log::Any>.  See L<Search::Elasticsearch::Logger::LogAny>
for more information.

=head2 Other

Other arguments are explained in the respective L<module docs|/MODULES>.

=head1 RUNNING REQUESTS

When you create a new instance of Search::Elasticsearch, it returns a
L<client|Search::Elasticsearch::Client::1_0::Direct> object, which can be used for
running requests.

    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new( %params );

    # create an index
    $e->indices->create( index => 'my_index' );

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

See L<Search::Elasticsearch::Client::1_0::Direct> for more details about the requests that
can be run.

=head1 MODULES

Each chunk of functionality is handled by a different module,
which can be specified in the call to L<new()> as shown in L<cxn_pool> above.
For instance, the following will use the L<Search::Elasticsearch::CxnPool::Sniff>
module for the connection pool.

    $e = Search::Elasticsearch->new(
        cxn_pool => 'Sniff'
    );

Custom modules can be named with the appropriate prefix,
eg C<Search::Elasticsearch::CxnPool::>, or by prefixing the full class name
with C<+>:

    $e = Search::Elasticsearch->new(
        cxn_pool => '+My::Custom::CxnClass'
    );

The modules that you can override are specified with the following
arguments to L</new()>:

=head2 C<client>

The class to use for the client functionality, which provides
methods that can be called to execute requests, such as
C<search()>, C<index()> or C<delete()>. The client parses the user's
requests and passes them to the L</transport> class to be executed.

The default version of the client is C<1_0::Direct>, which can
be explicitly specified as follows:

    $e = Search::Elasticsearch->new(
        client => '1_0::Direct'
    );

See :


=over

=item * L<Search::Elasticsearch::Client::1_0::Direct> (default, for 1.0 branch)

=item * L<Search::Elasticsearch::Client::2_0::Direct> (for 2.0 branch)

=item * L<Search::Elasticsearch::Client::0_90::Direct> (for 0.90 branch)

=item * L<Search::Elasticsearch::Client::Compat> (for migration from the old
L<ElasticSearch> module)

=back

=head2 C<transport>

The Transport class accepts a parsed request from the L</client> class,
fetches a L</cxn> from its L</cxn_pool> and tries to execute the request,
retrying after failure where appropriate. See:

=over

=item * L<Search::Elasticsearch::Transport>

=back

=head2 C<cxn>

The class which handles raw requests to Elasticsearch nodes.
See:

=over

=item * L<Search::Elasticsearch::Cxn::HTTPTiny> (default)

=item * L<Search::Elasticsearch::Cxn::Hijk>

=item * L<Search::Elasticsearch::Cxn::LWP>

=item * L<Search::Elasticsearch::Cxn::NetCurl>

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

=item * L<Search::Elasticsearch::CxnPool::Static> (default)

=item * L<Search::Elasticsearch::CxnPool::Sniff>

=item * L<Search::Elasticsearch::CxnPool::Static::NoPing>

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

=head1 MIGRATING FROM ElasticSearch.pm

See L<Search::Elasticsearch::Compat>, which allows you to run your old
L<ElasticSearch> code with the new L<Search::Elasticsearch> module.

The L<Search::Elasticsearch> API is pretty similar to the old L<ElasticSearch>
API, but there are a few differences.  The most notable are:

=head2 C<hosts> vs C<servers>

When instantiating a new Search::Elasticsearch instance, use C<nodes> instead
of C<servers>:

    $e = Search::Elasticsearch->new(
        nodes => [ 'search1:9200', 'search2:9200' ]
    );

=head2 C<no_refresh>

By default, the new client does not sniff the cluster to discover nodes.
To enable sniffing, use:

    $e = Search::Elasticsearch->new(
        cxn_pool => 'Sniff',
        nodes    => [ 'search1:9200', 'search2:9200' ]
    );

To disable sniffing (the equivalent of setting C<no_refresh> to C<true>), do:

    $e = Search::Elasticsearch->new(
        nodes    => [ 'search1:9200', 'search2:9200' ]
    );

=head2 Request parameters

In the old client, you could specify query string and body parameters at
the same level, eg:

    $e->search(
        search_type => 'count',
        query       => {
            match_all => {}
        }
    );

In the new client, body parameters should be passed in a C<body> element:

    $e->search(
        search_type => 'count',
        body        => {
            query       => {
                match_all => {}
            }
        }
    );

=head2 C<trace_calls>

The new client uses L<Log::Any> for event logging and request tracing.
To trace requests/responses in C<curl> format, do:

    # To STDERR
    $e = Search::Elasticsearch->new (trace_to => 'Stderr');

    # To a file
    $e = Search::Elasticsearch->new (trace_to => ['File','/path/to/file.log']);

=head2 SearchBuilder

The old API integrated L<ElasticSearch::SearchBuilder> for an L<SQL::Abstract>
style of writing queries and filters in Elasticsearch.
This integration does not exist in the new client.

=head2 Bulk methods and C<scrolled_search()>

Bulk indexing has changed a lot in the new client.  The helper methods, eg
C<bulk_index()> and C<reindex()> have been removed from the main client,
and the C<bulk()> method itself now simply returns the response from
Elasticsearch. It doesn't interfere with processing at all.

These helper methods have been replaced by the L<Search::Elasticsearch::Bulk>
class. Similarly, C<scrolled_search()> has been replaced by the
L<Search::Elasticsearch::Scroll>.  These helper classes are accessible as:

    $bulk   = $e->bulk_helper( %args_to_new );
    $scroll = $e->scroll_helper( %args_to_new );

=head1 BUGS

This is a stable API but this implementation is new. Watch this space
for new releases.

If you have any suggestions for improvements, or find any bugs, please report
them to L<http://github.com/elasticsearch/elasticsearch-perl/issues>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Search::Elasticsearch

You can also look for information at:

=over 4

=item * GitHub

L<http://github.com/elasticsearch/elasticsearch-perl>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Search::Elasticsearch>


=item * Search MetaCPAN

L<https://metacpan.org/module/Search::Elasticsearch>

=item * IRC

The L<#elasticsearch|irc://irc.freenode.net/elasticsearch> channel on
C<irc.freenode.net>.

=item * Mailing list

The main L<Elasticsearch mailing list|http://www.elastic.co/community>.

=back

=head1 TEST SUITE

The full test suite requires a live Elasticsearch node to run, and should
be run as :

    perl Makefile.PL
    ES=localhost:9200 make test

B<TESTS RUN IN THIS WAY ARE DESTRUCTIVE! DO NOT RUN AGAINST A CLUSTER WITH
DATA YOU WANT TO KEEP!>

You can change the Cxn class which is used by setting the C<ES_CXN>
environment variable:

    ES_CXN=Hijk ES=localhost:9200 make test
