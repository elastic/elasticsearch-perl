package Elasticsearch::Serializer;

use strict;
use warnings;
use namespace::autoclean;
use JSON;
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use Try::Tiny;
use Elasticsearch::Error qw(throw);

our $JSON;

#===================================
sub mime_type {'application/json'}
#===================================

#===================================
sub new {
#===================================
    my $class = shift;
    $JSON = JSON->new->utf8;
    return bless {}, $class;
}

#===================================
sub encode {
#===================================
    my $var = $_[1];

    if ( !ref $_[1] ) {
        return $_[1] unless is_utf8 $_[1];
        return encode_utf8( $_[1] );
    }

    return try {
        $JSON->encode($var);
    }
    catch {
        throw( "Serializer", $_, { var => $var } );
    };
}

#===================================
sub decode {
#===================================
    my $json = $_[1];

    return unless defined $json;

    return decode_utf8($json)
        unless substr( $json, 0, 1 ) =~ /^[\[{]/;

    return try {
        $JSON->decode($json);
    }
    catch {
        throw( "Serializer", $_, { json => $json } );
    };
}

1;
