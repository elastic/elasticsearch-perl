package Elasticsearch::Role::CxnPool;

use Moo::Role;
with 'Elasticsearch::Role::Error';
use Elasticsearch::Util qw(parse_params);
use namespace::autoclean;

use List::Util qw(shuffle);
use IO::Select();
use Time::HiRes qw(time sleep);
use Elasticsearch::Util qw(to_list);

requires qw(next_cxn schedule_check);

has 'cxn_factory'     => ( is => 'ro',  required => 1 );
has 'logger'          => ( is => 'ro',  required => 1 );
has 'serializer'      => ( is => 'ro',  required => 1 );
has 'current_cxn_num' => ( is => 'rwp', default  => 0 );
has 'cxns'            => ( is => 'rw',  default  => sub { [] } );
has 'seed_nodes'      => ( is => 'ro',  required => 1 );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my @seed = grep {$_} to_list( delete $params->{nodes} || ('') );

    @seed = $params->{cxn_factory}->default_host
        unless @seed;
    $params->{seed_nodes} = \@seed;
    return $params;
}

#===================================
sub next_cxn_num {
#===================================
    my $self = shift;
    my $cxns = $self->cxns;
    return unless @$cxns;
    $self->_set_current_cxn_num( ( $self->current_cxn_num + 1 ) % @$cxns );
}

#===================================
sub set_cxns {
#===================================
    my $self    = shift;
    my $factory = $self->cxn_factory;
    my @cxns    = map { $factory->new_cxn($_) } shuffle @_;
    $self->cxns( \@cxns );
    $self->_set_current_cxn_num(0);

    $self->logger->infof( "Current cxns: %s",
        [ map { $_->stringify } @cxns ] );

    return;
}

#===================================
sub cxns_str {
#===================================
    my $self = shift;
    join ", ", map { $_->stringify } @{ $self->cxns };
}

#===================================
sub cxns_seeds_str {
#===================================
    my $self = shift;
    join ", ", ( map { $_->stringify } @{ $self->cxns } ),
        @{ $self->seed_nodes };
}
1;
