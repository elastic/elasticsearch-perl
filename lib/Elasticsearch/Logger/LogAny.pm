package Elasticsearch::Logger::LogAny;

use Moo;
with 'Elasticsearch::Role::Error';
with 'Elasticsearch::Role::Logger';
use Elasticsearch::Util qw(parse_params to_list);
use namespace::autoclean;

use Log::Any();
use Log::Any::Adapter();

#===================================
sub _build_log_handle {
#===================================
    my $self = shift;
    if ( my @args = to_list( $self->log_to ) ) {
        Log::Any::Adapter->set( { category => $self->log_as }, @args );
    }
    Log::Any->get_logger( category => $self->log_as );
}

#===================================
sub _build_trace_handle {
#===================================
    my $self = shift;
    if ( my @args = to_list( $self->trace_to ) ) {
        Log::Any::Adapter->set( { category => $self->trace_as }, @args );
    }
    Log::Any->get_logger( category => $self->trace_as );
}

1;
