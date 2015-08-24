package Search::Elasticsearch::Role::Scroll;

use Moo::Role;
requires '_clear_scroll';
use Search::Elasticsearch::Util qw(parse_params throw);
use namespace::clean;

has 'es' => ( is => 'ro', required => 1 );
has 'scroll'        => ( is => 'ro' );
has 'scroll_in_qs'  => ( is => 'ro' );
has 'total'         => ( is => 'rwp' );
has 'max_score'     => ( is => 'rwp' );
has 'facets'        => ( is => 'rwp' );
has 'aggregations'  => ( is => 'rwp' );
has 'suggest'       => ( is => 'rwp' );
has 'took'          => ( is => 'rwp' );
has 'total_took'    => ( is => 'rwp' );
has 'search_params' => ( is => 'ro' );
has 'is_finished'   => ( is => 'rwp', default => '' );
has '_scroll_id'    => ( is => 'rwp', clearer => 1, predicate => 1 );
has '_pid'          => ( is => 'ro', default => $$ );

#===================================
sub finish {
#===================================
    my $self = shift;
    return unless ( $self->_pid() == $$ );
    return if $self->is_finished;
    $self->_set_is_finished(1);
    $self->_clear_scroll;
}

#===================================
sub scroll_request {
#===================================
    my $self = shift;
    my %args = ( scroll => $self->scroll );
    if ( $self->scroll_in_qs ) {
        $args{scroll_id} = $self->_scroll_id;
    }
    else {
        $args{body} = $self->_scroll_id;
    }
    $self->es->scroll(%args);
}

#===================================
sub DEMOLISH {
#===================================
    my $self = shift or return;
    $self->finish;
}

1;

# ABSTRACT: Provides common functionality to L<Search::Elasticseach::Scroll> and L<Search::Elasticsearch::Async::Scroll>
