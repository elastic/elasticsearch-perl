package Elasticsearch::Serializer;

use strict;
use warnings;
use namespace::autoclean;
use JSON;
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
    my $json;

    try {
        $json = $JSON->encode($var);
    }
    catch {
        throw( "Serializer", $_, { var => $var } );
    };
    return $json;
}

#===================================
sub decode {
#===================================
    my $json = $_[1];

    return unless defined $json;

    return $json
        unless substr( $json, 0, 1 ) =~ /^[\[{]/;

    my $var;
    try {
        $var = $JSON->decode($json);
    }
    catch {
        throw( "Serializer", $_, { json => $json } );
    };
    return $var;
}

1;
