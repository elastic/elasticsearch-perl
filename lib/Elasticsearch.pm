package Elasticsearch;

use Moo;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params load_plugin);

my %Default_Plugins = (
    client      => [ 'Client',       'Direct' ],
    cxn_factory => [ 'Cxn::Factory', '' ],
    cxn_pool    => [ 'CxnPool',      'Static' ],
    logger      => [ 'Logger',       'LogAny' ],
    serializer  => [ 'Serializer',   'JSON' ],
    transport   => [ 'Transport',    '' ],
);

my @Load_Order = qw(
    serializer
    logger
    cxn_factory
    cxn_pool
    transport
    client
);

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);

    $params->{cxn} ||= 'HTTPTiny';

    for my $name (@Load_Order) {
        my ( $base, $default ) = @{ $Default_Plugins{$name} };
        my $sub_class = $params->{$name} || $default;
        my $plugin_class = load_plugin( $base, $sub_class );
        $params->{$name} = $plugin_class->new($params);
    }
    return $params->{client};
}

1;
