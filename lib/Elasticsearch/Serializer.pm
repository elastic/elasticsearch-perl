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

    unless ( ref $var ) {
        return is_utf8($var)
            ? encode_utf8($var)
            : $var;
    }

    return try { $JSON->encode($var) }
    catch { throw( "Serializer", $_, { var => $var } ) };
}

#===================================
sub encode_pretty {
#===================================
    my ( $self, $var ) = @_;

    $JSON->pretty(1);

    my $json;
    try {
        $json = $self->encode($var);
    }
    catch {
        die "$_";
    }
    finally {
        $JSON->pretty(0);
    };

    return $json;
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
