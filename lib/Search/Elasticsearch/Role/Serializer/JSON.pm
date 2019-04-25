package Search::Elasticsearch::Role::Serializer::JSON;

use Moo::Role;
requires 'JSON';

use Search::Elasticsearch::Util qw(throw);
use Encode qw(encode_utf8 decode_utf8 is_utf8);
use namespace::clean;

has 'mime_type' => ( is => 'ro', default => 'application/json' );

with 'Search::Elasticsearch::Role::Serializer';

#===================================
sub encode {
#===================================
    my ( $self, $var ) = @_;
    unless ( ref $var ) {
        return is_utf8($var)
            ? encode_utf8($var)
            : $var;
    }
    my $result;
    unless (eval {
        $result = $self->JSON->encode($var);
        1;
    }) {
        throw( "Serializer", $@, { var => $var } );
    }
    return $result;
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
    unless (eval {
        for (@$var) {
            $json .= ( ref($_) ? $self->JSON->encode($_) : $_ ) . "\n";
        }
        1;
    }) {
        throw( "Serializer", $@, { var => $var } );
    }
    return $json;
}

#===================================
sub encode_pretty {
#===================================
    my ( $self, $var ) = @_;
    $self->JSON->pretty(1);

    my $json;
    unless (eval {
        $json = $self->encode($var);
        1;
    }) {
        my $error = $@;
        $self->JSON->pretty(0);
        die "$error";
    }
    $self->JSON->pretty(0);

    return $json;
}

#===================================
sub decode {
#===================================
    my ( $self, $json ) = @_;

    return unless defined $json;

    return is_utf8($json) ? $json : decode_utf8($json)
        unless substr( $json, 0, 1 ) =~ /^[\[{]/;

    my $result;
    unless (eval {
        $result = $self->JSON->decode($json);
        1;
    }) {
        throw( "Serializer", $@, { json => $json } );
    }
    return $result;
}

#===================================
sub _set_canonical {
#===================================
    shift()->JSON->canonical(1);
}

1;

__END__

# ABSTRACT: A Serializer role for JSON modules

=head1 DESCRIPTION

This role encodes Perl data structures into JSON strings, and
decodes JSON strings into Perl data structures.

=head1 METHODS

=head2 C<encode()>

    $bytes = $serializer->encode($ref);
    $bytes = $serializer->encode($str);

The L</encode()> method converts array and hash refs into their JSON
equivalents.  If a string is passed in, it is returned as the UTF8 encoded
version of itself.  The empty string and C<undef> are returned as is.

=head2 C<encode_pretty()>

    $bytes = $serializer->encode_pretty($ref);
    $bytes = $serializer->encode_pretty($str);

Works exactly as L</encode()> but the JSON output is pretty-printed.

=head2 C<encode_bulk()>

    $bytes = $serializer->encode_bulk([\%hash,\%hash,...]);
    $bytes = $serializer->encode_bulk([$str,$str,...]);

The L</encode_bulk()> method expects an array ref of hashes or strings.
Each hash or string is processed by L</encode()> then joined together
by newline characters, with a final newline character appended to the end.
This is the special JSON format used for bulk requests.

=head2 C<decode()>

    $var = $serializer->decode($json_bytes);
    $str = $serializer->decode($bytes);

If the passed in value looks like JSON (ie starts with a C<{> or C<[>
character), then it is decoded from JSON, otherwise it is returned as
the UTF8 decoded version of itself. The empty string and C<undef> are
returned as is.
