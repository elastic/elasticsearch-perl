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
    my $self     = shift;
    my $protocol = $self->protocol;
    $self->logger->infof( 'Sniffing [%s]', $self->stringify );
    $self->perform_request(
        {   method  => 'GET',
            path    => '/_nodes/' . $protocol,
            qs      => { timeout => 1000 * $self->sniff_timeout },
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

# ABSTRACT: Provides common functionality to Async Cxn implementations

