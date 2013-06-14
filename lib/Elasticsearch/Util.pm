package Elasticsearch::Util;

use strict;
use warnings;
use namespace::autoclean;

use Elasticsearch::Error('throw');
use Module::Runtime qw(compose_module_name is_module_name use_module);
use Scalar::Util qw(blessed);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(parse_params load_plugin init_instance code_to_error);

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
    my ( $base, $spec, $params ) = @_;
    $base = 'Elasticsearch::' . $base;
    $spec ||= $base;
    return $spec if blessed $spec;

    my ( $class, $version );
    if ( ref $spec eq 'ARRAY' ) {
        ( $class, $version ) = @$spec;
    }
    else {
        $class = $spec;
    }

    if ( $class =~ s/\A\+// ) {
        $class = compose_module_name( $base, $class );
    }
    use_module( $class, $version );
    return $class->new($params);
}

#===================================
sub init_instance {
#===================================
    my ( $obj, $required, $params ) = @_;

    for ( keys %$obj ) {
        $obj->{$_} = $params->{$_}
            if exists $params->{$_};
    }

    for (@$required) {
        $obj->{$_} = $params->{$_}
            or throw( "Param", "Missing required arg: $_" );
    }
    return $obj;
}

my %Code_To_Error = (
    409 => 'Conflict',
    404 => 'Missing',
    403 => 'ClusterBlocked',
    503 => 'NotReady'
);

#===================================
sub code_to_error { $Code_To_Error{ shift() || '' } }
#===================================

1;
