use Test::More;

BEGIN {
    eval { require JSON::XS; 1 } or do {
        plan skip_all => 'JSON::XS not installed';
        done_testing;
        exit;
        }
}

use Search::Elasticsearch::Async;

my $s = Search::Elasticsearch::Async->new()->transport->serializer;
isa_ok $s, "Search::Elasticsearch::Serializer::JSON::XS", 'JSON::XS';

done_testing;

