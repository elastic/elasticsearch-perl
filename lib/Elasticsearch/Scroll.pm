package Elasticsearch::Scroll;

use Moo;
use Elasticsearch::Util qw(parse_params);
use namespace::autoclean;

has 'es' => ( is => 'ro', required => 1 );
has 'scroll'     => ( is => 'ro' );
has 'total'      => ( is => 'ro' );
has 'max_score'  => ( is => 'ro' );
has 'facets'     => ( is => 'ro' );
has 'suggest'    => ( is => 'ro' );
has '_scroll_id' => ( is => 'rw' );
has '_buffer'    => ( is => 'ro' );
has 'eof'        => ( is => 'rw' );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $es        = delete $params->{es};
    my $on_result = delete $params->{on_result};
    my $scroll    = $params->{scroll} ||= '1m';
    my $results   = $es->search($params);

    return {
        es         => $es,
        scroll     => $scroll,
        total      => $results->{hits}{total},
        max_score  => $results->{hits}{max_score},
        facets     => $results->{facets},
        suggest    => $results->{suggest},
        _buffer    => $results->{hits}{hits},
        _scroll_id => $results->{_scroll_id},
    };
}

#===================================
sub next {
#===================================
    my ( $self, $n ) = @_;
    $n ||= 1;
    my $buffer = $self->_buffer;
    while ( !$self->eof and @$buffer < $n ) {
        $self->refill_buffer;
    }
    return splice( @$buffer, 0, $n );
}

#===================================
sub drain_buffer {
#===================================
    my $self = shift;
    return splice( @{ $self->buffer } );
}

#===================================
sub refill_buffer {
#===================================
    my $self    = shift;
    my $results = $self->es->scroll(
        scroll => $self->scroll,
        body   => $self->_scroll_id
    );
    $self->_scroll_id( $results->{_scroll_id} );
    my $hits = $results->{hits}{hits};
    if ( @$hits == 0 ) {
        $self->eof(1);
    }
    else {
        push @{ $self->_buffer }, @$hits;
    }

}

#===================================
sub finish {
#===================================
    my $self = shift;
    return if $self->eof;

    $self->es->clear_scroll( scroll_id => $self->_scroll_id );

    @{ $self->_buffer } = ();
    $self->eof(1);
}

#===================================
sub DESTROY {
#===================================
    my $self = shift;
    eval { $self->finish };
}

1;

__END__

# ABSTRACT: A helper utility for scrolled searches

=head1 DESCRIPTION

Docs to follow soon
