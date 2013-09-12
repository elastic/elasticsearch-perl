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
    my ( $self, $force ) = @_;

    my $cxns  = $self->cxns;
    my $total = @$cxns;

    while ( $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        return $cxn
            if $cxn->is_live
            || $cxn->pings_ok($force);
    }

    throw( "NoNodes", "No nodes are available: [", $self->cxns_str, ']' )
        if $force;

    return $self->next_cxn(1);
}

#===================================
sub schedule_check {
#===================================
    my $self = shift;
    $self->logger->info("Forcing ping before next use on all cxns");
    for my $cxn ( @{ $self->cxns } ) {
        $cxn->force_ping if $cxn->is_live
    }
}

1;
