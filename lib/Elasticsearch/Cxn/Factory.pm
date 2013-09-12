package Elasticsearch::Cxn::Factory;

use Moo;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;
use Elasticsearch::Util qw(parse_params load_plugin);

has '_factory'     => ( is => 'ro', required => 1 );
has 'default_host' => ( is => 'ro', required => 1 );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %args = (%$params);
    delete $args{nodes};

    my $cxn_class = load_plugin( 'Cxn', delete $args{cxn} );
    $params->{_factory} = sub {
        my ( $self, $node ) = @_;
        $cxn_class->new( %args, node => $node );
    };
    $params->{default_host} = $cxn_class->default_host;
    return $params;
}

#===================================
sub new_cxn { shift->_factory->(@_) }
#===================================

1
