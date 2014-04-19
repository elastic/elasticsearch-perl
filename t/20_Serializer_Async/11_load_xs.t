use Test::More;

use lib sub {
    die "No Cpanel" if $_[1] =~ m{Cpanel/JSON/XS.pm$};
    return undef;
};

use Search::Elasticsearch::Async;

my $s = Search::Elasticsearch::Async->new()->transport->serializer;

SKIP: {
    skip 'JSON::XS not installed' => 1
        unless eval { require JSON::XS; 1 };

    isa_ok $s, "Search::Elasticsearch::Serializer::JSON::XS", 'JSON::XS';
}

done_testing;

