package Elasticsearch::CxnPool::Static::NoPing;

use Moo;
with 'Elasticsearch::Role::CxnPool';
use namespace::autoclean;

has 'max_retries' => ( is => 'lazy' );
has '_dead_cxns' => ( is => 'ro', default => sub { [] } );

#===================================
sub _build_max_retries { @{ shift->cxns } - 1 }
sub _max_retries       { shift->max_retries + 1 }
#===================================

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->set_cxns( @{ $self->seed_nodes } );
}

#===================================
sub next_cxn {
#===================================
    my $self = shift;

    my $cxns  = $self->cxns;
    my $total = @$cxns;
    my $dead  = $self->_dead_cxns;

    while ( $total-- ) {
        my $cxn = $cxns->[ $self->next_cxn_num ];
        return $cxn
            if $cxn->is_live
            || $cxn->next_ping < time();
        push @$dead, $cxn unless grep { $_ eq $cxn } @$dead;
    }

    if ( @$dead and $self->retries <= $self->max_retries ) {
        $_->force_ping for @$dead;
        return shift @$dead;
    }
    throw( "NoNodes", "No nodes are available: [" . $self->cxns_str . ']' );
}

#===================================
sub should_mark_dead {
#===================================
    my ( $self, $error ) = @_;
    return $error->is( 'Cxn', 'Timeout' );
}

#===================================
after 'reset_retries' => sub {
#===================================
    my $self = shift;
    @{ $self->_dead_cxns } = ();

};

#===================================
sub schedule_check { }
#===================================

1;
