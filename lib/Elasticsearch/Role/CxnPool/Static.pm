package Elasticsearch::Role::CxnPool::Static;

use Moo::Role;
with 'Elasticsearch::Role::CxnPool';
requires 'next_cxn';

use namespace::clean;

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->set_cxns( @{ $self->seed_nodes } );
    $self->schedule_check;
}

#===================================
sub schedule_check {
#===================================
    my ($self) = @_;
    $self->logger->info("Forcing ping before next use on all live cxns");
    for my $cxn ( @{ $self->cxns } ) {
        next if $cxn->is_dead;
        $self->logger->infof( "Ping [%s] before next request",
            $cxn->stringify );
        $cxn->force_ping;
    }
}

1;

__END__

# ABSTRACT: A CxnPool role for connecting to a remote cluster with a static list of nodes.

=head1 METHODS

=head2 C<schedule_check()>

    $cxn_pool->schedule_check

Forces a ping on each cxn in L<cxns()|Elasticsearch::Role::CxnPool/cxns()>
before the next time that cxn is used for a request.

