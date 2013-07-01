use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

#trace;
test_files('spec/test/exists/*.yaml');

done_testing;
