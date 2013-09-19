use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/indices.get_mapping/10*.yaml');

done_testing;
