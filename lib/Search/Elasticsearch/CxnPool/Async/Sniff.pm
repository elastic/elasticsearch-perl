package Search::Elasticsearch::CxnPool::Async::Sniff;

use Moo;
with 'Search::Elasticsearch::Role::CxnPool::Sniff', 'Search::Elasticsearch::Role::Is_Async';

use Scalar::Util qw(weaken);
use Promises qw(deferred);
use Search::Elasticsearch::Util qw(new_error);

use namespace::clean;
has 'concurrent_sniff' => ( is => 'rw', default => 4 );
has '_current_sniff'   => ( is => 'rw', clearer => '_clear_sniff' );

#===================================
sub next_cxn {
#===================================
    my ( $self, $no_sniff ) = @_;

    return $self->sniff->then( sub { $self->next_cxn('no_sniff') } )
        if $self->next_sniff <= time() && !$no_sniff;

    my $cxns  = $self->cxns;
    my $total = @$cxns;
    my $cxn;

    while ( 0 < $total-- ) {
        $cxn = $cxns->[ $self->next_cxn_num ];
        last if $cxn->is_live;
        undef $cxn;
    }

    my $deferred = deferred;

    if ($cxn) {
        $deferred->resolve($cxn);
    }
    else {
        $deferred->reject(
            new_error(
                "NoNodes",
                "No nodes are available: [" . $self->cxns_seeds_str . ']'
            )
        );
    }
    return $deferred->promise;
}

#===================================
sub sniff {
#===================================
    my $self = shift;

    my $promise;
    if ( $promise = $self->_current_sniff ) {
        return $promise;
    }

    my $deferred   = deferred;
    my $cxns       = $self->cxns;
    my $total      = @$cxns;
    my $done       = 0;
    my $current    = 0;
    my $done_seeds = 0;
    $promise = $self->_current_sniff( $deferred->promise );

    my ( @all, @skipped );

    while ( 0 < $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        if ( $cxn->is_dead ) {
            push @skipped, $cxn;
        }
        else {
            push @all, $cxn;
        }
    }

    push @all, @skipped;
    unless (@all) {
        @all = $self->_seeds_as_cxns;
        $done_seeds++;
    }

    my ( $weak_check_sniff, $cxn );
    my $check_sniff = sub {

        return if $done;
        my ( $cxn, $nodes ) = @_;
        if ( $nodes && $self->parse_sniff( $cxn->protocol, $nodes ) ) {
            $done++;
            $self->_clear_sniff;
            return $deferred->resolve();
        }

        unless ( @all || $done_seeds++ ) {
            $self->logger->infof(
                "No live nodes available. Trying seed nodes.");
            @all = $self->_seeds_as_cxns;
        }

        if ( my $cxn = shift @all ) {
            return $cxn->sniff->done($weak_check_sniff);
        }
        if ( --$current == 0 ) {
            $self->_clear_sniff;
            $deferred->resolve();
        }
    };
    weaken( $weak_check_sniff = $check_sniff );

    for ( 1 .. $self->concurrent_sniff ) {
        my $cxn = shift(@all) || last;
        $current++;
        $cxn->sniff->done($check_sniff);
    }

    return $promise;
}

#===================================
sub _seeds_as_cxns {
#===================================
    my $self    = shift;
    my $factory = $self->cxn_factory;
    return map { $factory->new_cxn($_) } @{ $self->seed_nodes };
}

1;
