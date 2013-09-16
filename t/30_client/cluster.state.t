use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/cluster.state/*.yaml');

done_testing;
