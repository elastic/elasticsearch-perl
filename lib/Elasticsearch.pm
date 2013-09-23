package Elasticsearch;

use Moo;
use namespace::autoclean;

our $VERSION = '0.04';

use Elasticsearch::Util qw(parse_params load_plugin);

my %Default_Plugins = (
    client      => [ 'Client',       'Direct' ],
    cxn_factory => [ 'Cxn::Factory', '' ],
    cxn_pool    => [ 'CxnPool',      'Static' ],
    logger      => [ 'Logger',       'LogAny' ],
    serializer  => [ 'Serializer',   'JSON' ],
    transport   => [ 'Transport',    '' ],
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

    for my $name (@Load_Order) {
        my ( $base, $default ) = @{ $Default_Plugins{$name} };
        my $sub_class = $params->{$name} || $default;
        my $plugin_class = load_plugin( $base, $sub_class );
        $params->{$name} = $plugin_class->new($params);
    }
    return $params->{client};
}

1;

__END__

# ABSTRACT: The official client for Elasticsearch (beta)

=head1 SYNOPSIS

    use Elasticsearch;

Connect to C<localhost:9200>:

    my $e = Elasticsearch->new();

    # round-robin between two nodes
    my $e = Elasticsearch->new(
        nodes => [
            'search1:9200',
            'search2:9200'
        ]
    );

Connect to cluster at C<search1:9200>, sniff all nodes and
round-robin between them:

    my $e = Elasticsearch->new(
        nodes    => 'search1:9200',
        cxn_pool => 'Sniff'
    );

Index a document:

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

Get the document:

    my $doc = $e->get(
        index   => 'my_app',
        type    => 'blog_post',
        id      => 1
    );

Search:

    my $results = $e->search(
        index => 'my_app',
        body  => {
            query => {
                match => { title => 'elasticsearch' }
            }
        }
    );


=head1 DESCRIPTION

L<Elasticsearch> is the official Perl client for Elasticsearch, supported
by L<elasticsearch.com|http://www.elasticsearch.com>.  Elasticsearch
itself is a flexible and powerful open source, distributed real-time
search and analytics engine for the cloud.  You can read more about it
on L<elasticsearch.org|http://www.elasticsearch.org>.

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
L<Elasticsearch reference documentation|http://www.elasticsearch.org/guide>
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

HTTP backend (currently synchronous only - L<Any::Event> support will be added
later)

=item *

Robust networking support which handles load balancing, failure detection
and failover

=item *

Good defaults

=item *

Helper utilities for more complex operations, such as
L<bulk indexing|Elasticsearch::Util::Bulk>,
L<scrolled searches|Elasticsearch::Util::Scroll> and
L<reindexing|Elasticsearch::Util::Bulk/"reindex">.

=item *

Logging support via L<Log::Any>

=item *

Compatibility with the official clients for Python, Ruby, PHP and Javascript

=item *

Easy extensibility

=back

=head1 INSTALLING ELASTICSEARCH

You can download the latest version of Elasticsearch from
L<http://www.elasticsearch.org/download>. See the
L<installation instructions|http://www.elasticsearch.org/guide/reference/setup/installation/>
for details. You will need to have a recent version of Java installed,
preferably the Java v7 from Sun.

=head1 CREATING A NEW INSTANCE

The L</new()> method returns a new L<client|Elasticsearch::Client::Direct>
which can be used to run requests against the Elasticsearch cluster.

    use Elasticsearch;
    my $e = Elasticsearch->new( %params );

The most important arguments to L</new()> are the following:

=head2 C<nodes>

The C<nodes> parameter tells the client which Elasticsearch nodes it should
talk to.  It can be a single node, multiples nodes or, if not
specified, will default to C<localhost:9200>:

    # default: localhost:9200
    $e = Elasticsearch->new();

    # single
    $e = Elasticsearch->new( nodes => 'search_1:9200');

    # multiple
    $e = Elasticsearch->new(
        nodes => [
            'search_1:9200',
            'search_2:9200'
        ]
    );

Each C<node> can be a URL including a scheme, host, port, path and userinfo
(for authentication).  For instance, this would be a valid node:

    https://username:password@search.domain.com:443/prefix/path

See L<Elasticsearch::Role::Cxn::HTTP/node> for more on node specification.

=head2 C<cxn_pool>

The L<CxnPool|Elasticsearch::Role::CxnPool> modules manage connections to
nodes in the Elasticsearch cluster.  They handle the load balancing between
nodes and failover when nodes fail. Which C<CxnPool> you should use depends on
where your cluster is. There are three choices:

=over

=item * C<Static>

    $e = Elasticsearch->new(
        cxn_pool => 'Static'     # default
        nodes    => [
            'search1.domain.com:9200',
            'search2.domain.com:9200'
        ],
    );

The L<Static|Elasticsearch::CxnPool::Static> connection pool, which is the
default, should be used when you don't have direct access to the Elasticsearch
cluster, eg when you are accessing the cluster through a proxy.  See
L<Elasticsearch::CxnPool::Static> for more.

=item * C<Sniff>

    $e = Elasticsearch->new(
        cxn_pool => 'Sniff',
        nodes    => [
            'search1:9200',
            'search2:9200'
        ],
    );

The L<Sniff|Elasticsearch::CxnPool::Sniff> connection pool should be used
when you B<do> have direct access to the Elasticsearch cluster, eg when
your web servers and Elasticsearch servers are on the same network.
The nodes that you specify are used to I<discover> the cluster, which is
then I<sniffed> to find the current list of live nodes that the cluster
knows about. See L<Elasticsearch::CxnPool::Sniff>.

=item C<Static::NoPing>

    $e = Elasticsearch->new(
        cxn_pool => 'Static::NoPing'
        nodes    => [
            'proxy1.domain.com:80',
            'proxy2.domain.com:80'
        ],
    );

The L<Static::NoPing|Elasticsearch::CxnPool::Static::NoPing> connection
pool should be used when your access to a remote cluster is so limited
that you cannot ping individual nodes with a C<HEAD /> request.

See L<Elasticsearch::CxnPool::Static::NoPing> for more.

=back

=head2 C<trace_to>

For debugging purposes, it is useful to be able to dump the actual HTTP
requests which are sent to the cluster, and the response that is received.
This can be enabled with the C<trace_to> parametere, as follows:

    # To STDERR
    $e = Elasticsearch->new(
        trace_to => 'Stderr'
    );

    # To a file
    $e = Elasticsearch->new(
        trace_to => ['File','/path/to/filename']
    );

Logging is handled by L<Log::Any>.  See L<Elasticsearch::Logger::LogAny>
for more information.

=head2 Other

Other arguments are explained in the respective L<module docs|/MODULES>.

=head1 RUNNING REQUESTS

When you create a new instance of Elasticsearch, it returns a
L<client|Elasticsearch::Client::Direct> object, which can be used for
running requests.

    use Elasticsearch;
    my $e = Elasticsearch->new( %params );

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

See L<Elasticsearch::Client::Direct> for more details about the requests that
can be run.

=head1 MODULES

Each chunk of functionality is handled by a different module,
which can be specified in the call to L<new()> as shown in L<cxn_pool> above.
For instance, the following will use the L<Elasticsearch::CxnPool::Sniff>
module for the connection pool.

    $e = Elasticsearch->new(
        cxn_pool => 'Sniff'
    );

Custom modules can be named with the appropriate prefix,
eg C<Elasticsearch::CxnPool::>, or by prefixing the full class name
with C<+>:

    $e = Elasticsearch->new(
        cxn_pool => '+My::Custom::CxnClass'
    );

The modules that you can override are specfied with the following
arguments to L</new()>:

=head2 C<client>

The class to use for the client functionality, which provides
methods that can be called to execute requests, such as
C<search()>, C<index()> or C<delete()>. The client parses the user's
requests and passes them to the L</transport> class to be executed.
See :

=over

=item *

L<Elasticsearch::Client::Direct>.

=back

=head2 C<transport>

The Transport class accepts a parsed request from the L</client> class,
fetches a L</cxn> from its L</cxn_pool> and tries to execute the request,
retrying after failure where appropriate. See:

=over

=item *

L<Elasticsearch::Transport>

=back

=head2 C<cxn>

The class which handles raw requests to Elasticsearch nodes.
See:

=over

=item *

L<Elasticsearch::Cxn::HTTPTiny>

=back

=head2 C<cxn_factory>

The class which the L</cxn_pool> uses to create new L</cxn> objects.
See:

=over

=item *

L<Elasticsearch::Cxn::Factory>

=back

=head2 C<cxn_pool> (2)

The class to use for the L<connection pool|/cxn_pool> functionality.
It calls the L</cxn_factory> class to create new L</cxn> objects when
appropriate. See:

=over

=item *

L<Elasticsearch::CxnPool::Static> (default)

=item *

L<Elasticsearch::CxnPool::Sniff>

=item *

L<Elasticsearch::CxnPool::Static::NoPing>

=back

=head2 C<logger>

The class the use for logging events and tracing HTTP
requests/responses.  See:

=over

=item *

L<Elasticsearch::Logger::LogAny>

=back

=head2 C<serializer>

The class to use for serializing request bodies and deserializing response
bodies.  See:

=over

=item *

L<Elasticsearch::Serializer::JSON>

=back

=head1 TODO

