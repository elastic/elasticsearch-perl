package Elasticsearch::Cxn::Factory;

use Moo;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;
use Elasticsearch::Util qw(parse_params load_plugin);

has '_factory'           => ( is => 'ro', required => 1 );
has 'default_host'       => ( is => 'ro', required => 1 );
has 'max_content_length' => ( is => 'rw', default  => 104_857_600 );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %args = (%$params);
    delete $args{nodes};

    my $cxn_class = load_plugin( 'Cxn', delete $args{cxn} );
    $params->{_factory} = sub {
        my ( $self, $node ) = @_;
        $cxn_class->new(
            %args,
            node               => $node,
            max_content_length => $self->max_content_length
        );
    };
    $params->{default_host} = $cxn_class->default_host;
    $params->{cxn_args}     = \%args;
    $params->{cxn_class}    = $cxn_class;
    return $params;
}

#===================================
sub new_cxn { shift->_factory->(@_) }
#===================================

1
