use Test::More;
use Test::Deep;
use strict;
use warnings;
use lib 't/lib';

my $es = do "es_test_server.pl";

BEGIN { use_ok "Elasticsearch::Bulk" }

isa_ok my $b = Elasticsearch::Bulk->new( es => $es ), 'Elasticsearch::Bulk',
    'Bulk';

done_testing;

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
    $es->cluster_health( wait_for_color => 'green' );

    for my $i ( 10 .. 20 ) {
        $b->index( { id => $i, source => {} } );
    }

}
