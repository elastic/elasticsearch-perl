package Elasticsearch::Role::Logger;

use Moo::Role;
use namespace::autoclean;

requires qw(
    debug debugf info infof warn warnf error errorf
    critical criticalf is_debug is_info
    trace_request trace_response trace_error trace_comment
);

has 'serializer' => ( is => 'ro', required => 1 );
has 'trace_to'   => ( is => 'ro' );
has 'log_to'     => ( is => 'ro' );

#===================================
sub throw_error {
#===================================
    my ( $self, $type, $msg, $vars ) = @_;
    my $error = Elasticsearch::Error->new( $type, $msg, $vars, 1 );
    $self->error($error);
    die $error;
}

#===================================
sub throw_critical {
#===================================
    my ( $self, $type, $msg, $vars ) = @_;
    my $error = Elasticsearch::Error->new( $type, $msg, $vars, 1 );
    $self->critical($error);
    die $error;
}

1;
