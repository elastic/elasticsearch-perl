use Test::More;

eval { require Cpanel::JSON::XS; 1 } or do {
    plan skip_all => 'Cpanel::JSON::XS not installed';
    done_testing;
};

our $JSON_BACKEND = 'JSON::Cpanel';
do 't/20_Serializer/encode_decode.pl' or die $!;

