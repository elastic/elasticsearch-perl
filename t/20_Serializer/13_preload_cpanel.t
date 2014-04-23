use Test::More;

BEGIN {
    eval { require Cpanel::JSON::XS; 1 } or do {
        plan skip_all => 'Cpanel::JSON::XS not installed';
        done_testing;
        exit;
        }
}

use Search::Elasticsearch;

my $s = Search::Elasticsearch->new()->transport->serializer->JSON;
isa_ok $s, "Cpanel::JSON::XS", 'Cpanel';

done_testing;

