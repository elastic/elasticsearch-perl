use Test::More;

eval { require Cpanel::JSON::XS; 1 } or do {
    plan skip_all => 'Cpanel::JSON::XS not installed';
    done_testing;
};

use lib '.';
our $JSON_BACKEND = 'JSON::Cpanel';
do 't/20_Serializer_Async/encode_decode.pl' or die( $@ || $! );

