package Elasticsearch::API::Raw;

use strict;
use warnings;
use Elasticsearch::Util qw(parse_params init_instance);

my @Required_Params = qw(logger transport);

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $self = bless {}, $class;
    init_instance( $self, \@Required_Params, $params );
}

#===================================
sub logger    { $_[0]->{logger} }
sub transport { $_[0]->{transport} }
#===================================

1;
