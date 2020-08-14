# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

use Test::More;
use Test::Deep;
use Test::Exception;
use Search::Elasticsearch::Async;

our $JSON_BACKEND;
my $utf8_bytes = "彈性搜索";
my $utf8_str   = $utf8_bytes;
utf8::decode($utf8_str);
my $hash      = { "foo" => "$utf8_str" };
my $arr       = [$hash];
my $json_hash = qq({"foo":"$utf8_bytes"});
my $json_arr  = qq([$json_hash]);

isa_ok my $s
    = Search::Elasticsearch::Async->new( serializer => $JSON_BACKEND )
    ->transport->serializer,
    "Search::Elasticsearch::Serializer::$JSON_BACKEND", 'Serializer';

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
throws_ok { $s->decode('{') } qr/Serializer/, 'Dec - invalid JSON dies';

done_testing;
