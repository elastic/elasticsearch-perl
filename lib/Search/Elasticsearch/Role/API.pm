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

package Search::Elasticsearch::Role::API;

use Moo::Role;
requires 'api_version';
requires 'api';

use Scalar::Util qw(looks_like_number);
use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

our %Handler = (
    string  => \&_string,
    time    => \&_string,
    date    => \&_string,
    list    => \&_list,
    boolean => \&_bool,
    enum    => \&_list,
    number  => \&_num,
    int     => \&_num,
    integer => \&_num,
    float   => \&_num,
    double  => \&_num,
    "number|string" => \&_numOrString,
    "boolean|long"  => \&_booleanOrLong
);

#===================================
sub _bool {
#===================================
    my $val = _detect_bool(@_);
    return ( $val && $val ne 'false' ) ? 'true' : 'false';
}

#===================================
sub _detect_bool {
#===================================
    my $val = shift;
    return '' unless defined $val;
    if ( ref $val eq 'SCALAR' ) {
        return 'false' if $$val eq 0;
        return 'true'  if $$val eq 1;
    }
    elsif ( UNIVERSAL::isa( $val, "JSON::PP::Boolean" ) ) {
        return "$val" ? 'true' : 'false';
    }
    return "$val";
}

#===================================
sub _list {
#===================================
    return join ",", map { _detect_bool($_) }    #
        ref $_[0] eq 'ARRAY' ? @{ $_[0] } : $_[0];
}

#===================================
sub _num {
#===================================
    return 0 + $_[0];
}

#===================================
sub _string {
#===================================
    return "$_[0]";
}

#===================================
sub _numOrString {
#===================================
    if (looks_like_number($_[0])) {
        return _num($_[0]);
    }
    return _string($_[0]);
}

#===================================
sub _booleanOrLong {
#===================================
    if (looks_like_number($_[0])) {
        return _num($_[0]);
    }
    my $val = _detect_bool(@_);
    return ( $val && $val ne 'false' ) ? 'true' : 'false';
}

#===================================
sub _qs_init {
#===================================
    my $class = shift;
    my $API   = shift;
    for my $spec ( keys %$API ) {
        my $qs = $API->{$spec}{qs};
        for my $param ( keys %$qs ) {
            my $handler = $Handler{ $qs->{$param} }
                or throw( "Internal",
                      "Unknown type <"
                    . $qs->{$param}
                    . "> for param <$param> in API <$spec>" );
            $qs->{$param} = $handler;
        }
    }
}

1;

# ABSTRACT: Provides common functionality for API implementations
