use Test::More;
use Test::Deep;
use strict;
use warnings;
use lib 't/lib';
use Elasticsearch::Bulk;

my $es = do "es_sync.pl";

$es->indices->delete( index => '_all' );

test_flush(
    "max count",    #
    { max_count => 3 },    #
    1, 2, 0, 1, 2, 0, 1, 2, 0, 1
);

test_flush(
    "max size",            #
    { max_size => 95 },    #
    1, 2, 3, 0, 1, 2, 3, 0, 1, 2
);

test_flush(
    "max size > max_count",
    { max_size => 95, max_count => 3 },
    1, 2, 0, 1, 2, 0, 1, 2, 0, 1
);

test_flush(
    "max size < max_count",
    { max_size => 95, max_count => 5 },
    1, 2, 3, 0, 1, 2, 3, 0, 1, 2
);

test_flush(
    "max size = 0, max_count",
    { max_size => 0, max_count => 5 },
    1, 2, 3, 4, 0, 1, 2, 3, 4, 0
);

test_flush(
    "max count = 0, max_size",
    { max_size => 95, max_count => 0 },
    1, 2, 3, 0, 1, 2, 3, 0, 1, 2
);

test_flush(
    "max count = 0, max_size = 0",
    { max_size => 0, max_count => 0 },
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10
);

done_testing;

$es->indices->delete( index => 'test' );

#===================================
sub test_flush {
#===================================
    my $title  = shift;
    my $params = shift;
    my $b      = Elasticsearch::Bulk->new(
        %$params,
        index => 'test',
        type  => 'test',
        es    => $es
    );

    my @seq = @_;

    $es->indices->delete( index => 'test', ignore => 404 );
    $es->indices->create( index => 'test' );
    $es->cluster->health( wait_for_status => 'yellow' );

    for my $i ( 10 .. 19 ) {
        $b->index( { id => $i, source => {} } );
        is $b->_buffer_count, shift @seq, "$title - " . ( $i - 9 );
    }
    $b->flush;
    is $b->_buffer_count, 0, "$title - final flush";
    $es->indices->refresh;
    is $es->count->{count}, 10, "$title - all docs indexed";

}
