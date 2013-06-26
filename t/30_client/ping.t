use lib 't/lib';
use Elasticsearch::Client::Test;
use Test::More;

test_files('spec/test/ping/*.yaml');

done_testing;