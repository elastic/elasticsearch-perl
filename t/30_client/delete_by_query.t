use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/delete_by_query/*.yaml');

done_testing;
