package Elasticsearch::Util::API::QS;

use strict;
use warnings;

use Sub::Exporter -setup => { exports => ['qs_init'] };

our %Handler = (
    string => sub {"$_[0]"},
    list   => sub {
        ref $_[0] eq 'ARRAY'
            ? join( ',', @{ shift() } )
            : shift();
    },
    bool => sub { $_[0] ? 1 : 0 },
    enum => sub {"$_[0]"},
    number   => sub { 0 + $_[0] },
    datetime => sub {"$_[0]"},
    duration => sub {"$_[0]"},
);

our %Params = (
    all               => { type => 'bool' },
    allow_no_indices  => { type => 'bool' },
    analyze_wildcard  => { type => 'bool' },
    analyzer          => { type => 'string' },
    boost_terms       => { type => 'number' },
    clear             => { type => 'bool' },
    completion        => { type => 'bool' },
    completion_fields => { type => 'list' },
    consistency       => {
        options => [ 'one', 'quorum', 'all' ],
        type    => 'enum'
    },
    default_operator => {
        default => 'OR',
        options => [ 'AND', 'OR' ],
        type    => 'enum'
    },
    delay            => { type => 'duration' },
    df               => { type => 'string' },
    docs             => { type => 'bool' },
    dry_run          => { type => 'bool' },
    exit             => { type => 'bool' },
    expand_wildcards => { type => 'enum', options => [ 'open', 'closed' ] },
    explain          => { type => 'bool' },
    field            => { type => 'string' },
    fielddata        => { type => 'bool' },
    fielddata_fields => { type => 'list' },
    fields           => { type => 'list' },
    filter           => { type => 'bool' },
    filter_blocks    => { type => 'bool' },
    filter_cache     => { type => 'bool' },
    filter_index_templates => { type => 'bool' },
    filter_indices         => { type => 'list' },
    filter_keys            => { type => 'bool' },
    filter_metadata        => { type => 'bool' },
    filter_nodes           => { type => 'bool' },
    filter_routing_table   => { type => 'bool' },
    filters                => { type => 'list' },
    flat_settings          => { type => 'bool' },
    flush                  => { type => 'bool' },
    force                  => { type => 'bool' },
    format                 => {
        default => 'detailed',
        options => [ 'detailed', 'text' ],
        type    => 'enum'
    },
    from             => { type => 'number' },
    fs               => { type => 'bool' },
    full             => { type => 'bool' },
    get              => { type => 'bool' },
    groups           => { type => 'list' },
    http             => { type => 'bool' },
    id               => { type => 'string' },
    id_cache         => { type => 'bool' },
    ignore_conflicts => { type => 'bool' },
    ignore_indices   => {
        default => 'none',
        options => [ 'none', 'missing' ],
        type    => 'enum'
    },
    ignore             => { type => 'list', },
    ignore_unavailable => { type => 'bool' },
    include_defaults   => { type => 'bool' },
    index              => { type => 'list' },
    indexing           => { type => 'bool' },
    indices            => { type => 'bool' },
    indices_boost      => { type => 'list' },
    interval           => { type => 'duration' },
    jvm                => { type => 'bool' },
    lang               => { type => 'string' },
    lenient            => { type => 'bool' },
    level              => {
        options => [ 'cluster', 'node', 'indices', 'shards' ],
        type    => 'enum'
    },
    local                    => { type => 'bool' },
    lowercase_expanded_terms => { type => 'bool' },
    master_timeout           => { type => 'duration' },
    max_doc_freq             => { type => 'number' },
    max_num_segments         => { type => 'number' },
    max_query_terms          => { type => 'number' },
    max_word_len             => { type => 'number' },
    merge                    => { type => 'bool' },
    min_doc_freq             => { type => 'number' },
    min_score                => { type => 'number' },
    min_term_freq            => { type => 'number' },
    min_word_len             => { type => 'number' },
    mlt_fields               => { type => 'list' },
    name                     => { type => 'list' },
    network                  => { type => 'bool' },
    only_expunge_deletes     => { type => 'bool' },
    op_type                  => {
        default => 'index',
        options => [ 'index', 'create' ],
        type    => 'enum'
    },
    order                  => { type => 'number' },
    os                     => { type => 'bool' },
    parent                 => { type => 'string' },
    percent_terms_to_match => { type => 'number' },
    percolate              => { type => 'string' },
    plugin                 => { type => 'bool' },
    prefer_local           => { type => 'bool' },
    preference             => { type => 'string' },
    process                => { type => 'bool' },
    q                      => { type => 'string' },
    realtime               => { type => 'bool' },
    recovery               => { type => 'bool' },
    recycler               => { type => 'bool' },
    refresh                => { type => 'bool' },
    replication            => {
        default => 'sync',
        options => [ 'sync', 'async' ],
        type    => 'enum'
    },
    retry_on_conflict => { type => 'number' },
    routing           => { type => 'string' },
    script            => { type => 'string', },
    scroll            => { type => 'duration' },
    scroll_id         => { type => 'string' },
    search            => { type => 'bool' },
    search_from       => { type => 'number' },
    search_indices    => { type => 'list' },
    search_query_hint => { type => 'string' },
    search_scroll     => { type => 'string' },
    search_size       => { type => 'number' },
    search_source     => { type => 'string' },
    search_type       => {
        options => [
            'query_then_fetch',     'query_and_fetch',
            'dfs_query_then_fetch', 'dfs_query_and_fetch',
            'count',                'scan'
        ],
        type => 'enum'
    },
    search_types    => { type => 'list' },
    settings        => { type => 'bool' },
    size            => { type => 'number' },
    snapshot        => { type => 'bool' },
    snapshots       => { type => 'number' },
    sort            => { type => 'list' },
    source          => { type => 'string' },
    _source         => { type => 'list', },
    _source_exclude => { type => 'list', },
    _source_include => { type => 'list', },
    stats           => { type => 'list' },
    stop_words      => { type => 'list' },
    store           => { type => 'bool' },
    suggest_field   => { type => 'string' },
    suggest_mode    => {
        default => 'missing',
        options => [ 'missing', 'popular', 'always' ],
        type    => 'enum'
    },
    suggest_size => { type => 'number' },
    suggest_text => { type => 'string' },
    text         => { type => 'string' },
    thread_pool  => { type => 'bool' },
    threads      => { type => 'number' },
    timeout      => { type => 'duration' },
    timestamp    => { type => 'datetime' },
    tokenizer    => { type => 'string' },
    transport    => { type => 'bool' },
    ttl          => { type => 'duration' },
    type         => { type => 'string' },
    types        => { type => 'list' },
    version      => { type => 'number' },
    version_type => {
        type    => 'enum',
        options => [ 'internal', 'external' ]
    },
    wait_for_active_shards     => { type => 'number' },
    wait_for_merge             => { type => 'bool' },
    wait_for_nodes             => { type => 'string' },
    wait_for_relocating_shards => { type => 'number' },
    wait_for_status            => {
        default => undef,
        options => [ 'green', 'yellow', 'red' ],
        type    => 'enum'
    },
    warmer => { type => 'bool' }
);

#===================================
sub qs_init {
#===================================
    no warnings 'uninitialized';
    my %qs;
    for (@_) {
        my $defn = $Params{$_} || die("Unknown query-string param ($_)\n");
        $defn->{handler} ||= $Handler{ $defn->{type} }
            || die "Unknown query-string parameter type ($defn->{type})\n";
        $qs{$_} = $defn;
    }
    return \%qs;
}

1;

__END__

# ABSTRACT: A utility class for query string parameters in the API

=head1 DESCRIPTION

This class contains a definition of each query string parameter that
can be accepted by actions in the L<API|Elasticsearch::Role::API>.

=head1 EXPORTS

=head2 C<qs_init()>

    use Elasticsearch::Util::API::QS qw(qs_init);
    $handler = qs_init( @qs_params );
    $qs_hash = $handler->($params);

The C<qs_init()> sub accepts a list of query string parameter names,
and returns a handler which can extract those parameters from C<\%params>
and return a hash of values to be passed as a query string.

For instance:

    $handler = qs_init(qw(fields size from));
    $params  = { fields =>['foo','bar'], size => 10, query=>\%query };
    $qs_hash = $handler->($params);

Would result in:

    $qs_hash: { fields => 'foo,bar', size => 10};
    $params:   { query => \%query }

