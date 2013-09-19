package Elasticsearch::CxnPool::Static;

use Moo;
with 'Elasticsearch::Role::CxnPool';
use namespace::autoclean;

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->set_cxns( @{ $self->seed_nodes } );
    $self->schedule_check;
}

#===================================
sub next_cxn {
#===================================
    my ($self) = @_;

    my $cxns  = $self->cxns;
    my $total = @$cxns;

    my $now = time();
    my @skipped;

    while ( $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        return $cxn if $cxn->is_live;

        if ( $cxn->next_ping < $now ) {
            return $cxn if $cxn->pings_ok;
        }
        else {
            push @skipped, $cxn;
        }
    }

    for my $cxn (@skipped) {
        return $cxn if $cxn->pings_ok;
    }

    $_->force_ping for @$cxns;

    throw( "NoNodes", "No nodes are available: [" . $self->cxns_str . ']' );
}

#===================================
sub schedule_check {
#===================================
    my ($self) = @_;
    $self->logger->info("Forcing ping before next use on all cxns");
    for my $cxn ( @{ $self->cxns } ) {
        $cxn->force_ping if $cxn->is_live;
    }
}

1;
