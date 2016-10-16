package Search::Elasticsearch::Logger::LogAny;

use Moo;
with 'Search::Elasticsearch::Role::Logger';
use Search::Elasticsearch::Util qw(parse_params to_list);
use namespace::clean;

use Log::Any 1.02 ();
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

#===================================
sub _build_deprecate_handle {
#===================================
    my $self = shift;
    if ( my @args = to_list( $self->deprecate_to ) ) {
        Log::Any::Adapter->set( { category => $self->deprecate_as }, @args );
    }
    Log::Any->get_logger(
        default_adapter => 'Stderr',
        category        => $self->deprecate_as
    );
}

1;

# ABSTRACT: A Log::Any-based Logger implementation

=head1 DESCRIPTION

L<Search::Elasticsearch::Logger::LogAny> provides event logging and the tracing
of request/response conversations with Elasticsearch nodes via the
L<Log::Any> module.

I<Logging> refers to log events, such as node failures, pings, sniffs, etc,
and should be enabled for monitoring purposes.

I<Tracing> refers to the actual HTTP requests and responses sent
to Elasticsearch nodes.  Tracing can be enabled for debugging purposes,
or for generating a pretty-printed C<curl> script which can be used for
reporting problems.

I<Deprecations> refers to deprecation warnings returned by Elasticsearch
5.x and above. Deprecations are logged to STDERR by default.

=head1 CONFIGURATION

Logging and tracing can be enabled using L<Log::Any::Adapter>, or by
passing options to L<Search::Elasticsearch/new()>.

=head2 USING LOG::ANY::ADAPTER

Send all logging and tracing to C<STDERR>:

    use Log::Any::Adapter qw(Stderr);
    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new;

Send logging and deprecations to a file, and tracing to Stderr:

    use Log::Any::Adapter();
    Log::Any::Adapter->set(
        { category => 'elasticsearch.event' },
        'File',
        '/path/to/file.log'
    );
    Log::Any::Adapter->set(
        { category => 'elasticsearch.trace' },
        'Stderr'
    );
    Log::Any::Adapter->set(
        { category => 'elasticsearch.deprecation' },
        'File',
        '/path/to/deprecations.log'
    );

    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new;

=head2 USING C<log_to>, C<trace_to> AND C<deprecate_to>

Send all logging and tracing to C<STDERR>:

    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new(
        log_to   => 'Stderr',
        trace_to => 'Stderr',
        deprecate_to => 'Stderr'  # default
    );

Send logging and deprecations to a file, and tracing to Stderr:

    use Search::Elasticsearch;
    my $e = Search::Elasticsearch->new(
        log_to       => ['File', '/path/to/file.log'],
        trace_to     => 'Stderr',
        deprecate_to => ['File', '/path/to/deprecations.log'],
    );

See L<Log::Any::Adapter> for more.

