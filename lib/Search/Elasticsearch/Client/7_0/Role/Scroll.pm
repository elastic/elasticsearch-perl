package Search::Elasticsearch::Client::7_0::Role::Scroll;

use Moo::Role;
requires 'finish';
use Search::Elasticsearch::Util qw(parse_params throw);
use Devel::GlobalDestruction;
use namespace::clean;
has 'es' => ( is => 'ro', required => 1 );
has 'scroll'        => ( is => 'ro' );
has 'total'         => ( is => 'rwp' );
has 'max_score'     => ( is => 'rwp' );
has 'facets'        => ( is => 'rwp' );
has 'aggregations'  => ( is => 'rwp' );
has 'suggest'       => ( is => 'rwp' );
has 'took'          => ( is => 'rwp' );
has 'total_took'    => ( is => 'rwp' );
has 'search_params' => ( is => 'ro' );
has 'is_finished'   => ( is => 'rwp', default => '' );
has '_pid'          => ( is => 'ro', default => sub {$$} );
has '_scroll_id'    => ( is => 'rwp', clearer => 1, predicate => 1 );

#===================================
sub scroll_request {
#===================================
    my $self = shift;
    throw( 'Illegal',
              'Scroll requests are not fork safe and may only be '
            . 'refilled by the same process that created the instance.' )
        if $self->_pid != $$;

    my %args = ( scroll => $self->scroll );
    $args{body} = { scroll_id => $self->_scroll_id };
    $self->es->scroll(%args);
}

#===================================
sub DEMOLISH {
#===================================
    my $self = shift or return;
    return if in_global_destruction;
    $self->finish;
}

1;

# ABSTRACT: Provides common functionality to L<Search::Elasticsearch::Client::7_0::Scroll> and L<Search::Elasticsearch::Client::7_0::Async::Scroll>
