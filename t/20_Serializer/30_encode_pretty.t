use Test::More;
use Test::Deep;
use Test::Exception;
use Elasticsearch;

my $utf8_bytes = "彈性搜索";
my $utf8_str   = $utf8_bytes;
utf8::decode($utf8_str);
my $hash      = { "foo" => "$utf8_str" };
my $arr       = [$hash];
my $json_hash = <<JSON;
{
   "foo" : "$utf8_bytes"
}
JSON

my $json_arr = <<JSON;
[
   {
      "foo" : "$utf8_bytes"
   }
]
JSON

isa_ok my $s = Elasticsearch->new->transport->serializer,
    'Elasticsearch::Serializer::JSON', 'Serializer';

# encode
is $s->encode_pretty(), undef,    #
    'Enc - No args returns undef';
is $s->encode_pretty(undef), undef,    #
    'Enc - Undef returns undef';
is $s->encode_pretty(''), '',          #
    'Enc - Empty string returns same';
is $s->encode_pretty('foo'), 'foo',    #
    'Enc - String returns same';
is $s->encode_pretty($utf8_str), $utf8_bytes,    #
    'Enc - Unicode string returns encoded';
is $s->encode_pretty($utf8_bytes), $utf8_bytes,    #
    'Enc - Unicode bytes returns same';
is $s->encode_pretty($hash), $json_hash,           #
    'Enc - Hash returns JSON';
is $s->encode_pretty($arr), $json_arr,             #
    'Enc - Array returns JSON';
throws_ok { $s->encode_pretty( \$utf8_str ) } qr/Serializer/,    #
    'Enc - scalar ref dies';

done_testing;
