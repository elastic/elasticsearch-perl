use Test::More;
use Test::Deep;
use Test::Exception;
use lib 't/lib';

use strict;
use warnings;

our $es;

BEGIN {
    $es = do "es_sync.pl";
    use_ok 'Search::Elasticsearch::Scroll';
}

my $es_version = $es->info->{version}{number};

$es->indices->delete( index => '_all', ignore => 404 );

if ( $es_version ge '0.90.5' ) {
    test_scroll(
        "No indices",
        {},
        total     => 0,
        max_score => 0,
        steps     => [
            is_finished   => 1,
            next          => [0],
            refill_buffer => 0,
            drain_buffer  => [0],
        ]
    );
}

do "index_test_data.pl" or die $!;

test_scroll(
    "Match all",
    {},
    total     => 100,
    max_score => 1,
    steps     => [
        is_finished   => '',
        buffer_size   => 10,
        next          => [1],
        drain_buffer  => [9],
        refill_buffer => 10,
        refill_buffer => 20,
        is_finished   => '',
        next_81       => [81],
        next_20       => [9],
        next          => [0],
        is_finished   => 1,
    ]
);

SKIP: {
    skip "Bug in Elasticsearch suggest JSON parsing pre 0.90.3", 2
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
            }
        },
        total     => 50,
        max_score => num( 1.6, 0.5 ),
        aggs      => bool(1),
        facets    => bool(1),
        suggest   => bool(1),
        steps     => [
            next        => [1],
            next_50     => [49],
            is_finished => 1,
        ]
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
            }
        },
        total     => 50,
        max_score => num( 1.6, 0.5 ),
        aggs      => bool(1),
        facets    => bool(1),
        suggest   => bool(1),
        steps     => [
            next        => [1],
            next_50     => [49],
            is_finished => 1,
        ]
    );

    test_scroll(
        "Scan",
        {   search_type => 'scan',
            body        => {
                suggest => {
                    mysuggest =>
                        { text => 'green', term => { field => 'color' } }
                },
                facets => { color => { terms => { field => 'color' } } },
            }
        },
        total     => 100,
        max_score => 0,
        facets    => bool(1),
        suggest   => bool(1),
        steps     => [
            buffer_size => 0,
            next        => [1],
            buffer_size => 49,
            next_100    => [99],
            is_finished => 1,
        ]
    );

}

test_scroll(
    "Finish",
    {},
    total     => 100,
    max_score => 1,
    steps     => [
        is_finished => '',
        next        => [1],
        finish      => 1,
        is_finished => 1,
        buffer_size => 0,
        next        => [0]

    ]
);

my $s = $es->scroll_helper;
my $d = $s->next;
ok ref $d && $d->{_source}, 'next() in scalar context';

{
    # Test auto finish fork protection.
    my $s = $es->scroll_helper();
    ok( $s->_pid() , "Ok got a PID");

    my $pid = fork();
    unless( defined( $pid ) ){ die "Cannot fork. Lack of resources?"; }
    unless( $pid ){
        # Child. Call finish check that its not finished
        # (the call to finish did nothing).
        $s->finish();
        exit( $s->is_finished() ? 1 : 0 );
    }else{
        # Wait for children
        waitpid( $pid , 0 );
        cmp_ok( $?, '==', 0, "Ok good exit code. Child did not finish the Scroll");
    }
    ok( ! $s->is_finished(), "Ok our Scroll is not finished");
    $s->finish();
    ok( $s->is_finished(), "Ok can finish in the creating process");
}

{
    # Test Scroll usage attempt in a different process.
    my $s = Search::Elasticsearch::Scroll->new( es => $es , body => {});
    my $pid = fork();
    unless( defined( $pid ) ){ die "Cannot fork. Lack of resources?"; }
    unless( $pid ){
        # Calling this next should crash, not exiting this process with 0
        eval{ $s->next(); };
        my $err = $@;
        my $is_illegal_error = eval{ $err->is('Illegal'); };
        exit( $is_illegal_error ? 1 : 0 );
    }else{
        # Wait for children
        waitpid( $pid , 0 );
        cmp_ok( $?, '!=', 0, "Ok good exit code. Child did crash before exiting with 0");
    }
}

done_testing;
$es->indices->delete( index => 'test' );

#===================================
sub test_scroll {
#===================================
    my ( $title, $params, %tests ) = @_;
    delete $params->{body}{ $es_version ge '1' ? 'facets' : 'aggs' };

    subtest $title => sub {
        isa_ok my $s
            = Search::Elasticsearch::Scroll->new( es => $es, %$params ),
            'Search::Elasticsearch::Scroll', $title;

        is $s->total,             $tests{total},     "$title - total";
        cmp_deeply $s->max_score, $tests{max_score}, "$title - max_score";
        cmp_deeply $s->suggest,   $tests{suggest},   "$title - suggest";
        $es_version ge 1
            ? cmp_deeply $s->aggregations, $tests{aggs}, "$title - aggs"
            : cmp_deeply $s->facets, $tests{facets}, "$title - facets";

        my $i     = 1;
        my @steps = @{ $tests{steps} };
        while ( my $name = shift @steps ) {
            my $expect = shift @steps;
            my ( $method, $result, @p );
            if ( $name =~ /next(?:_(\d+))?/ ) {
                $method = 'next';
                @p      = $1;
            }
            else {
                $method = $name;
            }

            if ( ref $expect eq 'ARRAY' ) {
                my @result = $s->$method(@p);
                $result = 0 + @result;
                $expect = $expect->[0];
            }
            else {
                $result = $s->$method(@p);
            }

            is $result, $expect, "$title - Step $i: $name";
            $i++;
        }
        }
}

