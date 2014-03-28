package Search::Elasticsearch::CxnPool::Async::Static;

use Moo;
with 'Search::Elasticsearch::Role::CxnPool::Static', 'Search::Elasticsearch::Role::Is_Async';

use Search::Elasticsearch::Util qw(new_error);
use Scalar::Util qw(weaken);
use Promises qw(deferred);
use namespace::clean;

#===================================
sub next_cxn {
#===================================
    my ($self) = @_;

    my $cxns     = $self->cxns;
    my $now      = time();
    my $deferred = deferred;

    my ( %seen, @skipped, $weak_find_cxn );

    my $find_cxn = sub {
        my $total = @$cxns;
        my $found;

        if ( $total > keys %seen ) {

            # we haven't seen all cxns yet
            while ( $total-- ) {
                my $cxn = $cxns->[ $self->next_cxn_num ];
                next if $seen{$cxn}++;

                return $deferred->resolve($cxn)
                    if $cxn->is_live;

                if ($cxn->next_ping <= time()) {
                    $found = $cxn;
                    last;
                }

                push @skipped, $cxn;
            }
        }

        if ( $found ||= shift @skipped ) {
            return $found->pings_ok->then(
                sub { $deferred->resolve($found) },    # success
                $weak_find_cxn                       # resolve
            );
        }

        $_->force_ping for @$cxns;

        return $deferred->reject(
            new_error(
                "NoNodes",
                "No nodes are available: [" . $self->cxns_str . ']'
            )
        );

    };
    weaken( $weak_find_cxn = $find_cxn );

    $find_cxn->();
    $deferred->promise;
}

1;
__END__
