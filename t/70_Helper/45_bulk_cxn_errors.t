use Test::More;
use Test::Deep;
use Test::Exception;

use strict;
use warnings;
use lib 't/lib';
use Search::Elasticsearch::Bulk;
use Log::Any::Adapter;

$ENV{ES}           = '10.255.255.1:9200';
$ENV{ES_SKIP_PING} = 1;
$ENV{ES_CXN_POOL}  = 'Static';
$ENV{ES_TIMEOUT}   = 1;

my $es = do "es_sync.pl";
SKIP: {
    skip
        "IO::Socket::IP doesn't respect timeout: https://rt.cpan.org/Ticket/Display.html?id=103878",
        3
        if $es->transport->cxn_pool->cxn_factory->cxn_class eq
        'Search::Elasticsearch::Cxn::HTTPTiny'
        && $^V =~ /^v5.2\d/;

    # Check that the buffer is not cleared on a NoNodes exception

    my $b = $es->bulk_helper( index => 'foo', type => 'bar' );
    $b->create_docs( { foo => 'bar' } );

    is $b->_buffer_count, 1, "Buffer count pre-flush";
    throws_ok { $b->flush } 'Search::Elasticsearch::Error::NoNodes';
    is $b->_buffer_count, 1, "Buffer count post-flush";

}

done_testing;
