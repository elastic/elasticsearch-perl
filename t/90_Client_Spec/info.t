use lib 't/lib';
use Elasticsearch::Client::Test;
use Test::More;

test_files('spec/test/info/*.yaml');

done_testing;

