# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Role::API;

use Moo::Role;
requires 'api_version';
requires 'api';

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
    float   => \&_num,
    double  => \&_num,
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
