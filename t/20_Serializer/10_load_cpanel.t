use Test::More;

use Search::Elasticsearch;

my $s = Search::Elasticsearch->new()->transport->serializer->JSON;

SKIP: {
    skip 'Cpanel::JSON::XS not installed' => 1
        unless eval { require Cpanel::JSON::XS; 1 };

    isa_ok $s, "Cpanel::JSON::XS", 'Cpanel';
}

done_testing;

