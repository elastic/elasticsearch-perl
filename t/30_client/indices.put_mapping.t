use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/indices.put_mapping/*.yaml');

done_testing;
