use Test::More;

eval { require JSON::XS; 1 } or do {
    plan skip_all => 'JSON::XS not installed';
    done_testing;
};

our $JSON_BACKEND = 'JSON::XS';
do 't/20_Serializer/encode_decode.pl' or die $!;

