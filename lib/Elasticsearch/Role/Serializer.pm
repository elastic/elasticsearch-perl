package Elasticsearch::Role::Serializer;

use Moo::Role;
with 'Elasticsearch::Role::Error';

requires qw(encode decode encode_pretty mime_type);
use Encode qw(encode_utf8 decode_utf8 is_utf8);


1;
