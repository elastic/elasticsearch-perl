package Elasticsearch;

use Moo;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use Elasticsearch::Util qw(parse_params load_plugin);

my %Default_Plugins = (
    client     => [ 'Client',     'Raw' ],
    connection => [ 'Connection', 'HTTPTiny' ],
    logger     => [ 'Logger',     'LogAny' ],
    node_pool  => [ 'NodePool',   'Static' ],
    serializer => [ 'Serializer', 'JSON' ],
    transport  => [ 'Transport',  '' ],
);

my @Load_Order = qw(
    serializer logger
    connection node_pool
    transport  client
);

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);

    for my $name (@Load_Order) {
        my ( $base, $default ) = @{ $Default_Plugins{$name} };
        my $sub_class = $params->{$name} || $default;
        my $plugin_class = load_plugin( $base, $sub_class );
        $params->{$name} = $plugin_class->new($params);
    }
    return $params->{client};
}

1;
