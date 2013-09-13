package Elasticsearch::CxnPool::Static::NoPing;

use Moo;
with 'Elasticsearch::Role::CxnPool';
use namespace::autoclean;

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->set_cxns( @{ $self->seed_nodes } );
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
            if $force
            || $cxn->is_live
            || $cxn->next_ping < time();
    }

    throw( "NoNodes", "No nodes are available: [", $self->cxns_str, ']' )
        if $force;

    return $self->next_cxn(1);
}

#===================================
sub schedule_check { }
#===================================

1;
