package Search::Elasticsearch::Role::CxnPool::EC2Search;

use Moo::Role;
with 'Search::Elasticsearch::Role::CxnPool';
requires 'next_cxn', 'search_nodes';
use namespace::clean;

use Search::Elasticsearch::Util qw(parse_params);
use List::Util qw(min);
use Try::Tiny;

has 'search_interval'  => ( is => 'ro', default => 300 );
has 'ec2_use_iam_role' => ( is => 'ro', default => 0 );
has 'ec2_access_key'   => ( is => 'ro' );
has 'ec2_secret_key'   => ( is => 'ro' );
has 'ec2_region'       => ( is => 'ro' );
has 'ec2_filter'       => ( is => 'ro', default => sub { return { 'instance-state-name' => 'running' }} );
has 'ec2_node_build'   => ( is => 'ro', default => sub { 
                                return sub { 
                                    my $instance = shift;
                                    return $instance->dnsName . ':9200';
                                }
                            });
has 'next_search'      => ( is => 'rw', default => 0 );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    return $params;
}

#===================================
sub schedule_check {
#===================================
    my $self = shift;
    $self->logger->info("Require sniff before next request");
    $self->next_search(-1);
}

1;

__END__

# ABSTRACT: A CxnPool role for connecting to a local cluster with a dynamic node list

=head1 CONFIGURATION

=head2 C<search_interval>

How often should we perform a search in order to detect whether new nodes
have been added to the cluster.  Defaults to `300` seconds.

=head2 C<ec2_filter>

The filter passed to L<VM::EC2> describe_instances to filter the list 
instance list.  By default all running instances are returned.

=head2 C<ec2_node_build>

A callback that builds the actual node connection specification passed
a L<VM::EC::Instance> object and should return a connection string.

=head1 METHODS

=head2 C<schedule_check()>

    $cxn_pool->schedule_check

Schedules a search before the next request is processed.
