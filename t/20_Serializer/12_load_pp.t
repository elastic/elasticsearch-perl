use Test::More;

use lib sub {
    die "No Cpanel"   if $_[1] =~ m{Cpanel/JSON/XS.pm$};
    die "No JSON::XS" if $_[1] =~ m{JSON/XS.pm$};
    return undef;
};

use Search::Elasticsearch;

my $s = Search::Elasticsearch->new()->transport->serializer;

SKIP: {
    skip 'JSON::PP not installed' => 1
        unless eval { require JSON::PP; 1 };

    isa_ok $s, "Search::Elasticsearch::Serializer::JSON::PP", 'JSON::PP';
}

done_testing;

