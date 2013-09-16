use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/indices.validate_query/*.yaml');

done_testing;
