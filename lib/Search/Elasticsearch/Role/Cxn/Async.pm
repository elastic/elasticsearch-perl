package Search::Elasticsearch::Role::Cxn::Async;

use Moo::Role;

use Search::Elasticsearch::Util qw(new_error);
use namespace::clean;

#===================================
sub pings_ok {
#===================================
    my $self = shift;
    $self->logger->infof( 'Pinging [%s]', $self->stringify );

    $self->perform_request(
        {   method  => 'HEAD',
            path    => '/',
            timeout => $self->ping_timeout,
        }
        )->then(
        sub {
            $self->logger->infof( 'Marking [%s] as live', $self->stringify );
            $self->mark_live;
        },
        sub {
            $self->logger->debug(@_);
            $self->mark_dead;
            die(@_);
        }
        );
}

#===================================
sub sniff {
#===================================
    my $self = shift;
    $self->logger->infof( 'Sniffing [%s]', $self->stringify );
    $self->perform_request(
        {   method  => 'GET',
            path    => '/_nodes/http',
            qs      => { timeout => $self->sniff_timeout . 's' },
            timeout => $self->sniff_request_timeout,
        }
        )->then(
        sub { ( $self, $_[1]->{nodes} ) },
        sub {
            $self->mark_dead;
            $self->logger->debug(@_);
            ($self);
        }
        );
}
1;

# ABSTRACT: Provides common functionality to async Cxn implementations

=head1 DESCRIPTION

L<Search::Elasticsearch::Role::Cxn::Async> provides common functionality to the
async Cxn implementations. Cxn instances are created by a
L<Search::Elasticsearch::Role::CxnPool> implementation,
using the L<Search::Elasticsearch::Cxn::Factory> class.

=head1 CONFIGURATION

See L<Search::Elasticsearch::Role::Cxn> for configuration options.

=head1 METHODS

None of the methods listed below are useful to the user. They are
documented for those who are writing alternative implementations only.


=head2 C<pings_ok()>

    $promise = $cxn->pings_ok

Try to ping the node and call L</mark_live()> or L</mark_dead()> depending on
the success or failure of the ping.

=head2 C<sniff()>

    $cxn->sniff
        ->then(
            sub { my ($cxn,$nodes) = @_; ... },
            sub { my $cxn = shift; ... }
          )

Send a sniff request to the node and return the response.

