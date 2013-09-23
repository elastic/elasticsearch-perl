package Elasticsearch::Util;

use Moo;
use Elasticsearch::Error();
use Scalar::Util qw(blessed);
use Module::Runtime qw(compose_module_name is_module_name use_module);
use Sub::Exporter -setup => {
    exports => [ qw(
            parse_params
            to_list
            load_plugin
            throw
            upgrade_error
            )
    ]
};

#===================================
sub to_list {
#===================================
    grep {defined} ref $_[0] eq 'ARRAY' ? @{ $_[0] } : @_;
}

#===================================
sub parse_params {
#===================================
    my $self = shift;
    my %params;
    if ( @_ % 2 ) {
        throw(
            "Param",
            'Expecting a HASH ref or a list of key-value pairs',
            { params => \@_ }
        ) unless ref $_[0] eq 'HASH';
        %params = %{ shift() };
    }
    else {
        %params = @_;
    }
    return ( $self, \%params );
}

#===================================
sub load_plugin {
#===================================
    my ( $base, $spec ) = @_;
    $base = 'Elasticsearch::' . $base;
    $spec ||= "+$base";
    return $spec if blessed $spec;

    my ( $class, $version );
    if ( ref $spec eq 'ARRAY' ) {
        ( $class, $version ) = @$spec;
    }
    else {
        $class = $spec;
    }

    unless ( $class =~ s/\A\+// ) {
        $class = compose_module_name( $base, $class );
    }
    use_module( $class, $version );
    return $class;
}

#===================================
sub throw {
#===================================
    my ( $type, $msg, $vars ) = @_;
    die Elasticsearch::Error->new( $type, $msg, $vars, 1 );
}

#===================================
sub upgrade_error {
#===================================
    my ( $error, $vars ) = @_;
    return ref($error) && $error->isa('Elasticsearch::Error')
        ? $error
        : Elasticsearch::Error->new( "Internal", $error, $vars || {}, 1 );
}

1;

# ABSTRACT: A utility class for internal use by Elasticsearch
