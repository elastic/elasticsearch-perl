package Elasticsearch::Logger;

use strict;
use warnings;
use Carp;
use Elasticsearch::Util qw(parse_params init_instance);

my @Required_Params = qw();

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $self = bless {}, $class;
    init_instance( $self, \@Required_Params, $params );
}

1;
