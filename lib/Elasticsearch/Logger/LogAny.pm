package Elasticsearch::Logger::LogAny;

use Moo;
with 'Elasticsearch::Role::Error';
with 'Elasticsearch::Role::Logger';
use namespace::autoclean;

use Log::Any();
use Log::Any::Adapter();
use URI();

#===================================
sub BUILDARGS {
#===================================
    my $class = shift;
    my %params = ref $_[0] ? %{ shift() } : @_;
    if ( my $args = delete $params{log_to} ) {
        Log::Any::Adapter->set( { category => 'elasticsearch' },
            ref $args ? @$args : $args );
    }
    $params{log_to} = Log::Any->get_logger( category => 'elasticsearch' );

    if ( my $args = $params{trace_to} ) {
        Log::Any::Adapter->set( { category => 'elasticsearch.trace' },
            ref $args ? @$args : $args );
    }
    $params{trace_to}
        = Log::Any->get_logger( category => 'elasticsearch.trace' );

    return \%params;
}

1;
