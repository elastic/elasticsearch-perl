use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/get_source/*.yaml');

done_testing;
