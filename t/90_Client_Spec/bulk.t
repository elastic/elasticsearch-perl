use lib 't/lib';
use Test::More;
use Elasticsearch::Client::Test;

test_files('spec/test/bulk/*.yaml');

#         qs        => qs_init qw(consistency refresh replication type),

done_testing;
