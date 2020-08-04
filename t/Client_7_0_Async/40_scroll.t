use Test::More;
use Test::Deep;
use Test::Exception;
use lib 't/lib';

use strict;
use warnings;

our ( $s, $total_seen, $max_seen );
$ENV{ES_VERSION} = '7_0';
our $es = do "es_async.pl" or die( $@ || $! );

wait_for( $es->indices->delete( index => '_all', ignore => 404 ) );

test_scroll(
    "No indices",
    { on_results => \&on_results },
    total      => 0,
    max_score  => 0,
    total_seen => 0,
    max_seen   => 0,
);

do "index_test_data_7.pl" or die( $@ || $! );

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

test_scroll(
    "Query",
    {   body => {
            query   => { term => { color => 'red' } },
            suggest => {
                mysuggest => { text => 'green', term => { field => 'color' } }
            },
            aggs => { switch => { terms => { field => 'switch' } } },
        },
        size       => 10,
        on_results => \&on_results
    },
    total      => 50,
    max_score  => num( 1.0, 0.5 ),
    aggs       => bool(1),
    suggest    => bool(1),
    total_seen => 50,
    max_seen   => 10
);

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

{
    # Test auto finish fork protection.
    my $count = 0;
    my $s = $es->scroll_helper( size => 5, on_result => sub { $count++ } );

    my $pid = fork();
    unless ( defined($pid) ) { die "Cannot fork. Lack of resources?"; }
    unless ($pid) {

        # Child. Call finish check that its not finished
        # (the call to finish did nothing).
        wait_for( $s->finish() );
        exit 0;
    }
    else {
        # Wait for children
        waitpid( $pid, 0 );
        is $?, 0, "Child exited without errors";
    }
    ok !$s->is_finished(), "Our Scroll is not finished";
    wait_for( $s->start );
    is $count, 100, "All documents retrieved";
    ok $s->is_finished, "Our scroll is finished";
}

# {
#     # Test Scroll usage attempt in a different process.
#     my $count = 0;
#     my $s     = $es->scroll_helper(
#         size      => 5,
#         on_result => sub { $count++ },
#         on_error  => sub { die @_ }
#     );

#     my $pid = fork();
#     unless ( defined($pid) ) { die "Cannot fork. Lack of resources?"; }
#     unless ($pid) {

#         eval { wait_for( $s->start ) };
#         my $err = $@;
#         exit( eval { $err->is('Illegal') && 123 } || 999 );
#     }
#     else {
#         # Wait for children
#         waitpid( $pid, 0 );
#         is $? >> 8, 123, "Child threw Illegal exception";
#     }
# }

# {
#     # Test valid Scroll usage after initial fork
#     my $pid = fork();
#     unless ( defined($pid) ) { die "Cannot fork. Lack of resources?"; }
#     unless ($pid) {

#         my $count = 0;
#         my $s     = $es->scroll_helper(
#             size      => 5,
#             on_result => sub { $count++ },
#             on_error  => sub { die @_ }
#         );

#         wait_for( $s->start );
#         exit 0;
#     }
#     else {
#         # Wait for children
#         waitpid( $pid, 0 );
#         is $? , 0, "Scroll completed successfully";
#     }
# }

done_testing;

wait_for( $es->indices->delete( index => 'test' ) );

#===================================
sub test_scroll {
#===================================
    my ( $title, $params, %tests ) = @_;
    $max_seen = $total_seen = 0;
    subtest $title => sub {
        $s = $es->scroll_helper(
            on_start => sub { test_start( $title, \%tests, @_ ) },
            %$params
        );
        wait_for( $s->start );

        is $total_seen, $tests{total_seen}, "$title - total seen";
        is $max_seen,   $tests{max_seen},   "$title - max seen";

    };
}

#===================================
sub test_start {
#===================================
    my ( $title, $tests, $s ) = @_;
    is $s->total,                $tests->{total},     "$title - total";
    cmp_deeply $s->max_score,    $tests->{max_score}, "$title - max_score";
    cmp_deeply $s->suggest,      $tests->{suggest},   "$title - suggest";
    cmp_deeply $s->aggregations, $tests->{aggs},      "$title - aggs";

}

#===================================
sub on_results {
#===================================
    $max_seen = @_ if @_ > $max_seen;
    $total_seen += @_;
}
