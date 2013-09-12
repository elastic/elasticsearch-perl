package Elasticsearch::Util;

use Moo;
with 'Elasticsearch::Role::Error';

use Scalar::Util qw(blessed);
use Module::Runtime qw(compose_module_name is_module_name use_module);
use Sub::Exporter -setup => {
    exports => [ qw(
            parse_params
            to_list
            load_plugin
            install_actions
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
sub install_actions {
#===================================
    my $group = shift() || '';
    my ($class) = caller;

    my $defns = $class->api;
    my $stash = Package::Stash->new($class);

    for my $action ( keys %$defns ) {
        my ( $prefix, $name ) = ( $action =~ /^(?:([^.]*)\.)?([^.]+)$/ );
        $prefix ||= '';
        next unless $prefix eq $group;

        next if $stash->has_symbol( '&' . $name );

        my $defn = $defns->{$action};
        $stash->add_symbol(
            '&' . $name => sub {
                shift->perform_request( $action, $defn, @_ );
            }
        );
    }
}

1;
