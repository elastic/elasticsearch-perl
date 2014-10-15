package Search::Elasticsearch::CxnPool::EC2Search;

use Moo;
with 'Search::Elasticsearch::Role::CxnPool::EC2Search',
    'Search::Elasticsearch::Role::Is_Sync';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;
use VM::EC2::Security::CredentialCache;
use VM::EC2;

#===================================
sub next_cxn {
#===================================
    my ($self) = @_;

    $self->search_nodes if $self->next_search <= time();

    my $cxns  = $self->cxns;
    my $total = @$cxns;

    while ( 0 < $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        return $cxn if $cxn->is_live;
    }

    throw( "NoNodes",
           "No nodes are available: []" );
}

#===================================
sub search_nodes {
#===================================
    my $self = shift;

    $self->logger->infof("No live nodes available. Trying to get EC2Search result.");

    my $ec2;
    if ($self->ec2_use_iam_role) {
        $ec2 = VM::EC2::Security::CredentialCache->get()->new_ec2;
    } else {
        $ec2 = VM::EC2->new(-access_key => $self->ec2_access_key,
                            -secret_key => $self->ec2_secret_key,
                            (defined($self->ec2_region) ? (-region => $self->ec2_region) : ()),
                        );
    }

    
    my $ref = $self->ec2_node_build;
    $self->set_cxns(map { 
        $ref->($_);
    } $ec2->describe_instances(-filter => $self->ec2_filter));
    
    my $next = $self->next_search( time() + $self->search_interval );
    $self->logger->infof( "Next search at: %s", scalar localtime($next) );
}


1;

# ABSTRACT: A CxnPool for connecting to a local cluster with a dynamic node list

=head1 SYNOPSIS

    # For example use all machines that have a tag named machine_type set to search
    # use a IAM role for authentication

    $e = Search::Elasticsearch->new(
        cxn_pool => 'EC2Search',
        ec2_use_iam_role => 1,
        ec2_filter => {
          'instance-state-name' => "running",
          "tag:machine_type" => "search"
        },
        ec2_node_build => sub {
          my $instance = shift;
          return 'https://' . $instance->dnsName;
        }
    );

=head1 DESCRIPTION

The L<EC2Search|Search::Elasticsearch::CxnPool::EC2Search> connection pool should be used
when you B<do> have direct access to the Elasticsearch cluster, eg when
your web servers and Elasticsearch servers are on the same network.
The nodes that you specify are used to I<discover> the cluster, which is
then I<sniffed> to find the current list of live nodes that the cluster
knows about.

This sniff process is repeated regularly, or whenever a node fails,
to update the list of healthy nodes.  So if you add more nodes to your
cluster, they will be auto-discovered during a sniff.

If all sniffed nodes fail, then it falls back to sniffing the original
I<seed> nodes that you specified in C<new()>.

For L<HTTP Cxn classes|Search::Elasticsearch::Role::Cxn::HTTP>, this module
will also dynamically detect the C<max_content_length> which the nodes
in the cluster will accept.

This class does L<Search::Elasticsearch::Role::CxnPool::EC2Search> and
L<Search::Elasticsearch::Role::Is_Sync>.

=head1 CONFIGURATION

=head2 C<nodes>

The list of nodes to use to discover the cluster.  Can accept a single node,
multiple nodes, and defaults to C<localhost:9200> if no C<nodes> are
specified. See L<Search::Elasticsearch::Role::Cxn::HTTP/node> for details of the node
specification.

=head2 See also

=over

=item *

L<Search::Elasticsearch::Role::Cxn/request_timeout>

=back

=head2 Inherited configuration

From L<Search::Elasticsearch::Role::CxnPool::EC2Search>

=over

=item * L<search_interval|Search::Elasticsearch::Role::CxnPool::EC2Search/"search_interval">

=item * L<search_interval|Search::Elasticsearch::Role::CxnPool::EC2Search/"ec2_filter">

=item * L<search_interval|Search::Elasticsearch::Role::CxnPool::EC2Search/"ec2_node_builder">

=back

From L<Search::Elasticsearch::Role::CxnPool>

=over

=item * L<randomize_cxns|Search::Elasticsearch::Role::CxnPool/"randomize_cxns">

=back

=head1 METHODS

=head2 C<next_cxn()>

    $cxn = $cxn_pool->next_cxn

Returns the next available live node (in round robin fashion), or
throws a C<NoNodes> error if no nodes can be sniffed from the cluster.

=head2 C<schedule_check()>

    $cxn_pool->schedule_check

Forces a sniff before the next Cxn is returned, to updated the list of healthy
nodes in the cluster.

=head2 C<sniff()>

    $bool = $cxn_pool->sniff

Retrieves the nodes from EC2 and returns C<true> if the request was successful.

=head2 Inherited methods

From L<Search::Elasticsearch::Role::CxnPool::EC2Search>

=over

=item * L<schedule_check()|Search::Elasticsearch::Role::CxnPool::EC2Search/"schedule_check()">

=back

From L<Search::Elasticsearch::Role::CxnPool>

=item * L<cxn_factory()|Search::Elasticsearch::Role::CxnPool/"cxn_factory()">

=item * L<logger()|Search::Elasticsearch::Role::CxnPool/"logger()">

=item * L<serializer()|Search::Elasticsearch::Role::CxnPool/"serializer()">

=item * L<current_cxn_num()|Search::Elasticsearch::Role::CxnPool/"current_cxn_num()">

=item * L<cxns()|Search::Elasticsearch::Role::CxnPool/"cxns()">

=item * L<seed_nodes()|Search::Elasticsearch::Role::CxnPool/"seed_nodes()">

=item * L<next_cxn_num()|Search::Elasticsearch::Role::CxnPool/"next_cxn_num()">

=item * L<set_cxns()|Search::Elasticsearch::Role::CxnPool/"set_cxns()">

=item * L<request_ok()|Search::Elasticsearch::Role::CxnPool/"request_ok()">

=item * L<request_failed()|Search::Elasticsearch::Role::CxnPool/"request_failed()">

=item * L<should_retry()|Search::Elasticsearch::Role::CxnPool/"should_retry()">

=item * L<should_mark_dead()|Search::Elasticsearch::Role::CxnPool/"should_mark_dead()">

=item * L<cxns_str()|Search::Elasticsearch::Role::CxnPool/"cxns_str()">

=item * L<cxns_seeds_str()|Search::Elasticsearch::Role::CxnPool/"cxns_seeds_str()">

=item * L<retries()|Search::Elasticsearch::Role::CxnPool/"retries()">

=item * L<reset_retries()|Search::Elasticsearch::Role::CxnPool/"reset_retries()">

=back

