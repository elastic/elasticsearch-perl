use Test::More;
use Test::Deep;
use Test::Exception;

use strict;
use warnings;
use lib 't/lib';
use Search::Elasticsearch::Bulk;
use Log::Any::Adapter;

$ENV{ES}           = '127.0.0.2:9200';
$ENV{ES_SKIP_PING} = 1;
$ENV{ES_CXN_POOL}  = 'Static';
$ENV{ES_TIMEOUT}   = 1;

my $es = do "es_sync.pl";

# Check that the buffer is not cleared on a NoNodes exception

my $b = $es->bulk_helper( index => 'foo', type => 'bar' );
$b->create_docs( { foo => 'bar' } );

is $b->_buffer_count, 1, "Buffer count pre-flush";
throws_ok { $b->flush } 'Search::Elasticsearch::Error::NoNodes';
is $b->_buffer_count, 1, "Buffer count post-flush";

done_testing;
