use Test::More;
use Test::Deep;
use Test::Exception;
use Elasticsearch;

my $utf8_bytes = "彈性搜索";
my $utf8_str   = $utf8_bytes;
utf8::decode($utf8_str);
my $hash      = { "foo" => "$utf8_str" };
my $arr       = [$hash];
my $json_hash = qq({"foo":"$utf8_bytes"});
my $json_arr  = qq([$json_hash]);

isa_ok my $s = Elasticsearch->new->transport->serializer,
    'Elasticsearch::Serializer::JSON', 'Serializer';

is $s->mime_type, 'application/json', 'Mime type is JSON';

# encode
is $s->encode(), undef, 'Enc - No args returns undef';
is $s->encode(undef), undef, 'Enc - Undef returns undef';
is $s->encode(''),    '',    'Enc - Empty string returns same';
is $s->encode('foo'), 'foo', 'Enc - String returns same';
is $s->encode($utf8_str), $utf8_bytes, 'Enc - Unicode string returns encoded';
is $s->encode($utf8_bytes), $utf8_bytes, 'Enc - Unicode bytes returns same';
is $s->encode($hash),       $json_hash,  'Enc - Hash returns JSON';
is $s->encode($arr),        $json_arr,   'Enc - Array returns JSON';
throws_ok { $s->encode( \$utf8_str ) } qr/Serializer/,
    'Enc - scalar ref dies';

# decode
is $s->decode(), undef, 'Dec - No args returns undef';
is $s->decode(undef), undef, 'Dec - Undef returns undef';
is $s->decode(''),    '',    'Dec - Empty string returns same';
is $s->decode('foo'), 'foo', 'Dec - String returns same';
is $s->decode($utf8_bytes), $utf8_str, 'Dec - Unicode bytes returns decoded';
is $s->decode($utf8_str),   $utf8_str, 'Dec - Unicode string returns same';
cmp_deeply $s->decode($json_hash), $hash, 'Dec - JSON returns hash';
cmp_deeply $s->decode($json_arr),  $arr,  'Dec - JSON returns array';
throws_ok { $s->decode('{') } qr/Serializer/, 'DEc - invalid JSON dies';

done_testing;
