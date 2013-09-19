use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/get/*.yaml');

done_testing;
