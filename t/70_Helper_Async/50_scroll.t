use Test::More;
use Test::Deep;
use Test::Exception;
use lib 't/lib';

use strict;
use warnings;

our ( $es, $es_version, $s, $total_seen, $max_seen );

BEGIN {
    $es = do "es_async.pl";
    use_ok 'Search::Elasticsearch::Async::Scroll';
}

wait_for( $es->indices->delete( index => '_all', ignore => 404 )
        ->then( sub { $es->info } )
        ->then( sub { $es_version = shift()->{version}{number} } ) );

if ( $es_version ge '0.90.5' ) {
    test_scroll(
        "No indices",
        { on_results => \&on_results },
        total      => 0,
        max_score  => 0,
        total_seen => 0,
        max_seen   => 0,
    );
}

do "index_test_data.pl" or die $!;

test_scroll(
    "Match all - on_result",
    { on_result => \&on_results, size => 10 },
    total      => 100,
    max_score  => 1,
    total_seen => 100,
    max_seen   => 1
);

test_scroll(
    "Match all - on_results",
    { on_results => \&on_results, size => 10 },
    total      => 100,
    max_score  => 1,
    total_seen => 100,
    max_seen   => 10
);

SKIP: {
    skip
        "Bug in Search::Elasticsearch::Async suggest JSON parsing pre 0.90.3",
        2
        if $es_version lt '0.90.3';

    test_scroll(
        "Query",
        {   body => {
                query   => { term => { color => 'red' } },
                suggest => {
                    mysuggest =>
                        { text => 'green', term => { field => 'color' } }
                },
                facets => { color => { terms => { field => 'color' } } },
                aggs   => { color => { terms => { field => 'color' } } },
            },
            size       => 10,
            on_results => \&on_results
        },
        total      => 50,
        max_score  => num( 1.6, 0.2 ),
        facets     => bool(1),
        aggs       => bool(1),
        suggest    => bool(1),
        total_seen => 50,
        max_seen   => 10
    );

    test_scroll(
        "Scroll in qs",
        {   scroll_in_qs => 1,
            body         => {
                query   => { term => { color => 'red' } },
                suggest => {
                    mysuggest =>
                        { text => 'green', term => { field => 'color' } }
                },
                facets => { color => { terms => { field => 'color' } } },
                aggs   => { color => { terms => { field => 'color' } } },
            },
            size       => 10,
            on_results => \&on_results
        },
        total      => 50,
        max_score  => num( 1.6, 0.2 ),
        facets     => bool(1),
        aggs       => bool(1),
        suggest    => bool(1),
        total_seen => 50,
        max_seen   => 10
    );

    test_scroll(
        "Scan",
        {   body => {
                query   => { term => { color => 'red' } },
                suggest => {
                    mysuggest =>
                        { text => 'green', term => { field => 'color' } }
                },
                facets => { color => { terms => { field => 'color' } } },
            },
            size        => 5,
            on_results  => \&on_results,
            search_type => 'scan'
        },
        total      => 50,
        max_score  => 0,
        facets     => bool(1),
        suggest    => bool(1),
        total_seen => 50,
        max_seen   => 25
    );

}

test_scroll(
    "Finish",
    {   on_results => sub {
            on_results(@_);
            $s->finish if $total_seen == 30;
        },
        size => 10
    },
    total      => 100,
    max_score  => 1,
    total_seen => 30,
    max_seen   => 10
);

done_testing;

wait_for( $es->indices->delete( index => 'test' ) );

#===================================
sub test_scroll {
#===================================
    my ( $title, $params, %tests ) = @_;
    $max_seen = $total_seen = 0;
    delete $params->{body}{ $es_version ge '1' ? 'facets' : 'aggs' };
    subtest $title => sub {
        isa_ok $s = Search::Elasticsearch::Async::Scroll->new(
            es       => $es,
            on_start => sub { test_start( $title, \%tests, @_ ) },
            %$params
            ),
            'Search::Elasticsearch::Async::Scroll', $title;
        wait_for( $s->start );

        is $total_seen, $tests{total_seen}, "$title - total seen";
        is $max_seen,   $tests{max_seen},   "$title - max seen";

    };
}

#===================================
sub test_start {
#===================================
    my ( $title, $tests, $s ) = @_;
    is $s->total,             $tests->{total},     "$title - total";
    cmp_deeply $s->max_score, $tests->{max_score}, "$title - max_score";
    cmp_deeply $s->suggest,   $tests->{suggest},   "$title - suggest";
    $es_version ge 1
        ? cmp_deeply $s->aggregations, $tests->{aggs}, "$title - aggs"
        : cmp_deeply $s->facets, $tests->{facets}, "$title - facets";

}

#===================================
sub wait_for {
#===================================
    my $promise = shift;
    my $cv      = AE::cv;
    $promise->done( $cv, sub { $cv->croak } );
    $cv->recv;
}

#===================================
sub on_results {
#===================================
    $max_seen = @_ if @_ > $max_seen;
    $total_seen += @_;
}
