use Test::More;
use Test::Deep;
use Test::Exception;
use lib 't/lib';

use strict;
use warnings;
use Elasticsearch::Scroll;
use Elasticsearch::Bulk;

our $es = do "es_sync.pl";
my $is_0_90 = $es->info->{version}{number} =~ /^0.90/;

$es->indices->delete( index => '_all', ignore => 404 );
do "index_test_data.pl" or die $!;

my $b;

# Reindex to new index and new type
$b = Elasticsearch::Bulk->new( es => $es, index => 'test2', type => 'test2' );
$b->reindex( source => { index => 'test' } );
$es->indices->refresh;

is $es->count(
    index => 'test2',
    type  => 'test2'
    )->{count}, 100,
    'Reindexed to new index and type';

# Reindex to same index
$b = Elasticsearch::Bulk->new( es => $es );
$b->reindex( source => { index => 'test' } );
$es->indices->refresh;

is $es->count(
    index => 'test',
    type  => 'test'
    )->{count}, 100,
    'Reindexed to same index';

is $es->get( index => 'test', type => 'test', id => 1 )->{_version}, 2,
    "Reindexed to same index - version updated";

# Reindex with transform
$es->indices->delete( index => 'test2' );

$b = Elasticsearch::Bulk->new( es => $es, index => 'test2' );
$b->reindex(
    source    => { index => 'test' },
    transform => sub {
        my $doc = shift;
        return if $doc->{_source}{color} eq 'red';
        $doc->{_source}{transformed} = 1;
        return $doc;
    }
);
$es->indices->refresh;

is $es->count(
    index => 'test2',
    type  => 'test'
    )->{count}, 50,
    'Transfrom - removed docs';

my $query = {
    bool => {
        must => [
            { term => { color       => 'green' } },
            { term => { transformed => 1 } }
        ]
    }
};
unless ($is_0_90) {
    $query = { query => $query };
}

is $es->count(
    index => 'test2',
    type  => 'test',
    body  => $query,
    )->{count}, 50,
    'Transfrom - transformed docs';

# Reindex with parent & routing
$es->indices->delete( index => '_all', ignore => 404 );
for ( 'test', 'test2' ) {
    $es->indices->create(
        index => $_,
        body  => { mappings => { test => { _parent => { type => 'foo' } } } }
    );
}
$es->cluster->health( wait_for_status => 'yellow' );

for ( 1 .. 5 ) {
    $es->index(
        index        => 'test',
        type         => 'test',
        version_type => 'external',
        version      => $_,
        id           => $_,
        parent       => 1,
        routing      => 2,
        body         => { count => $_ },
    );
}
$es->indices->refresh;

$b = Elasticsearch::Bulk->new( es => $es, index => 'test2' );
ok $b->reindex(
    version_type => 'external',
    source       => {
        index   => 'test',
        version => 1,
        fields  => [ '_parent', '_routing', '_source' ]
    }
    ),
    "Advanced";

$es->indices->refresh;
my $results = $es->search(
    index   => 'test2',
    type    => 'test',
    sort    => 'count',
    fields  => [ '_parent', '_routing' ],
    version => 1,
)->{hits}{hits};
is $results->[3]{fields}{_parent},  1, "Advanced - parent";
is $results->[3]{fields}{_routing}, 2, "Advanced - routing";
is $results->[3]{_version}, 4, "Advanced - version";

done_testing;
