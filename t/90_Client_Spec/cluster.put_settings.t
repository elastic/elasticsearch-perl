use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/cluster.put_settings/*.yaml');

done_testing;
