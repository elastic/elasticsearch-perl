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

isa_ok my $s
    = Search::Elasticsearch::Async->new( serializer => $JSON_BACKEND )
    ->transport->serializer,
    "Search::Elasticsearch::Serializer::$JSON_BACKEND", 'Serializer';

# encode
is_pretty( [],            undef,       'Enc - No args returns undef' );
is_pretty( [undef],       undef,       'Enc - Undef returns undef' );
is_pretty( [''],          '',          'Enc - Empty string returns same' );
is_pretty( ['foo'],       'foo',       'Enc - String returns same' );
is_pretty( [$utf8_str],   $utf8_bytes, 'Enc - Unicode string returns encoded' );
is_pretty( [$utf8_bytes], $utf8_bytes, 'Enc - Unicode bytes returns same' );
is_pretty( [$hash],       $json_hash,  'Enc - Hash returns JSON' );
is_pretty( [$arr],        $json_arr,   'Enc - Array returns JSON' );

throws_ok { $s->encode_pretty( \$utf8_str ) } qr/Serializer/,    #
    'Enc - scalar ref dies';

sub is_pretty {
    my ( $arg, $expect, $desc ) = @_;
    my $got = $s->encode_pretty(@$arg);
    defined $got    and $got =~ s/^\s+//gm;
    defined $expect and $expect =~ s/^\s+//gm;
    is $got, $expect, $desc;
}

done_testing;
