use Test::More;
use Search::Elasticsearch;

my $pool
    = Search::Elasticsearch->new( cxn_pool => 'Sniff' )->transport->cxn_pool;

is $pool->_extract_host('127.0.0.1:9200'), '127.0.0.1:9200', "IP";

is $pool->_extract_host('myhost/127.0.0.1:9200'), '127.0.0.1:9200', "Host/IP";

is $pool->_extract_host('inet[127.0.0.1:9200]'), '127.0.0.1:9200', "inet[IP]";

is $pool->_extract_host('inet[myhost/127.0.0.1:9200]'), '127.0.0.1:9200',
    "inet[Host/IP]";

is $pool->_extract_host('inet[/127.0.0.1:9200]'), '127.0.0.1:9200',
    "inet[/IP]";

ok !$pool->_extract_host(), "Undefined";

done_testing;
