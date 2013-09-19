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
has 'retries'         => ( is => 'rw',  default  => 0 );
has 'max_retries'     => ( is => 'rw',  default  => 2 );
has 'randomize_cxns'  => ( is => 'ro',  default  => 1 );

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
    my $current = $self->current_cxn_num;
    $self->_set_current_cxn_num( ($current +1 ) % @$cxns );
    return $current;
}

#===================================
sub set_cxns {
#===================================
    my $self    = shift;
    my $factory = $self->cxn_factory;
    my @cxns    = map { $factory->new_cxn($_) } @_;
    @cxns = shuffle @cxns if $self->randomize_cxns;
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

#===================================
sub reset_retries { shift->retries(0) }
#===================================

#===================================
before 'next_cxn' => sub {
#===================================
    my ( $self, $force ) = @_;
    return if $force;

    my $retries = $self->retries( $self->retries + 1 );
    if ( $retries > $self->max_retries ) {
        die "Retried request $retries times";
    }
    return 1;

};

1;
