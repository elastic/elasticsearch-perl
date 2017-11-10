use Test::More;

eval { require JSON::PP; 1 } or do {
    plan skip_all => 'JSON::PP not installed';
    done_testing;
};

our $JSON_BACKEND = 'JSON::PP';
do './t/20_Serializer/encode_decode.pl' or die( $@ || $! );

