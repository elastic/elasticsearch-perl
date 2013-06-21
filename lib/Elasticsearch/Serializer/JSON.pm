package Elasticsearch::Serializer::JSON;

use Moo;

use namespace::autoclean;
use JSON();
use Try::Tiny;

our $JSON = JSON->new->utf8;

has 'mime_type' => ( is => 'ro', default => 'application/json' );

with 'Elasticsearch::Role::Serializer';

#===================================
sub encode {
#===================================
    my ( $self, $var ) = @_;
    unless ( ref $var ) {
        return is_utf8($var)
            ? encode_utf8($var)
            : $var;
    }
    return try { $JSON->encode($var) }
    catch { throw( "Serializer", $_, { var => $var } ) };
}

#===================================
sub encode_bulk {
#===================================
    my ( $self, $var ) = @_;
    unless ( ref $var ) {
        return is_utf8($var)
            ? encode_utf8($var)
            : $var;
    }

    my $json = '';
    throw( "Param", "Var must be an array ref" )
        unless ref $var eq 'ARRAY';
    return try {
        for (@$var) {
            $json .= $JSON->encode($var) . "\n";
        }
        return $json;
    }
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
