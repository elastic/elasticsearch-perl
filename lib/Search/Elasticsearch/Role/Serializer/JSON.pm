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

package Search::Elasticsearch::Role::Serializer::JSON;

use Moo::Role;
requires 'JSON';

use Search::Elasticsearch::Util qw(throw);
use Try::Tiny;
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
    return try { $self->JSON->encode($var) }
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
            $json .= ( ref($_) ? $self->JSON->encode($_) : $_ ) . "\n";
        }
        return $json;
    }
    catch { throw( "Serializer", $_, { var => $var } ) };
}

#===================================
sub encode_pretty {
#===================================
    my ( $self, $var ) = @_;
    $self->JSON->pretty(1);

    my $json;
    try {
        $json = $self->encode($var);
    }
    catch {
        die "$_";
    }
    finally {
        $self->JSON->pretty(0);
    };

    return $json;
}

#===================================
sub decode {
#===================================
    my ( $self, $json ) = @_;

    return unless defined $json;

    return is_utf8($json) ? $json : decode_utf8($json)
        unless substr( $json, 0, 1 ) =~ /^[\[{]/;

    return try {
        $self->JSON->decode($json);
    }
    catch {
        throw( "Serializer", $_, { json => $json } );
    };
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
