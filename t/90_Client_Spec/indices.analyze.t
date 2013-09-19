use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

trace_file;
test_files('spec/test/indices.analyze/*.yaml');

done_testing;
