package Search::Elasticsearch::Util::API::QS;

use strict;
use warnings;

use Sub::Exporter -setup => { exports => [ 'qs_init', 'register_qs' ] };

our %Handler = (
    string => sub {"$_[0]"},
    list   => sub {
        ref $_[0] eq 'ARRAY'
            ? join( ',', @{ shift() } )
            : shift();
    },
    bool => sub { $_[0] ? 'true' : 'false' },
    enum => sub {
        ref $_[0] eq 'ARRAY'
            ? join( ',', @{ shift() } )
            : shift();
    },
    number   => sub { 0 + $_[0] },
    datetime => sub {"$_[0]"},
    duration => sub {"$_[0]"},
);

our %Params = (
    actions           => { type => 'list' },
    active            => { type => 'bool' },
    active_only       => { type => 'bool' },
    all               => { type => 'bool' },
    allow_no_indices  => { type => 'bool' },
    analyze_wildcard  => { type => 'bool' },
    analyzer          => { type => 'string' },
    attributes        => { type => 'list' },
    boost_terms       => { type => 'number' },
    bytes             => { type => 'enum', options => [ 'b', 'k', 'm', 'g' ] },
    char_filters      => { type => 'list' },
    clear             => { type => 'bool' },
    completion        => { type => 'bool' },
    completion_fields => { type => 'list' },
    conflicts => {
        type    => 'enum',
        options => [ 'abort', 'proceed' ],
        default => 'abort'
    },
    consistency => {
        options => [ 'one', 'quorum', 'all' ],
        type    => 'enum'
    },
    create           => { type => 'bool' },
    debug            => { type => 'bool' },
    default_operator => {
        default => 'OR',
        options => [ 'AND', 'OR' ],
        type    => 'enum'
    },
    delay            => { type => 'duration' },
    detail           => { type => 'bool' },
    detailed         => { type => 'bool' },
    detect_noop      => { type => 'bool' },
    df               => { type => 'string' },
    dfs              => { type => 'bool' },
    docs             => { type => 'bool' },
    dry_run          => { type => 'bool' },
    exit             => { type => 'bool' },
    expand_wildcards => {
        type    => 'enum',
        options => [ 'open', 'closed', 'none', 'all' ]
    },
    explain                => { type => 'bool' },
    field                  => { type => 'string' },
    field_statistics       => { type => 'bool' },
    fielddata              => { type => 'bool' },
    fielddata_fields       => { type => 'list' },
    fields                 => { type => 'list' },
    filter                 => { type => 'bool' },
    filter_blocks          => { type => 'bool' },
    filter_cache           => { type => 'bool' },
    filter_index_templates => { type => 'bool' },
    filter_indices         => { type => 'list' },
    filter_keys            => { type => 'bool' },
    filter_path            => { type => 'list' },
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
    full_id          => { type => 'bool' },
    get              => { type => 'bool' },
    groups           => { type => 'list' },
    http             => { type => 'bool' },
    h                => { type => 'list' },
    help             => { type => 'bool' },
    human            => { type => 'bool' },
    id               => { type => 'string' },
    id_cache         => { type => 'bool' },
    ids              => { type => 'list' },
    ignore_conflicts => { type => 'bool' },
    ignore_indices   => {
        default => 'none',
        options => [ 'none', 'missing' ],
        type    => 'enum'
    },
    ignore              => { type => 'list', },
    ignore_idle_threads => { type => 'bool' },
    ignore_unavailable  => { type => 'bool' },
    include_defaults    => { type => 'bool' },
    index               => { type => 'list' },
    index_templates     => { type => 'list' },
    indexing            => { type => 'bool' },
    indices             => { type => 'bool' },
    interval            => { type => 'duration' },
    jvm                 => { type => 'bool' },
    lang                => { type => 'string' },
    lenient             => { type => 'bool' },
    level               => {
        options => [ 'cluster', 'node', 'indices', 'shards' ],
        type    => 'enum'
    },
    local                    => { type => 'bool' },
    lowercase_expanded_terms => { type => 'bool' },
    master_timeout           => { type => 'duration' },
    max_doc_freq             => { type => 'number' },
    max_num_segments         => { type => 'number' },
    max_query_terms          => { type => 'number' },
    max_word_len             => { type => 'number' },     # depr 0.90
    max_word_length          => { type => 'number' },
    metric                   => {
        type    => 'enum',
        options => [
            "_all",          "blocks",      "metadata", "nodes",
            "routing_table", "master_node", "version"
        ]
    },
    merge                 => { type => 'bool' },
    min_doc_freq          => { type => 'number' },
    min_score             => { type => 'number' },
    min_term_freq         => { type => 'number' },
    min_word_len          => { type => 'number' },    # depr 0.90
    min_word_length       => { type => 'number' },
    mlt_fields            => { type => 'list' },
    name                  => { type => 'list' },
    network               => { type => 'bool' },
    node_id               => { type => 'list' },
    offsets               => { type => 'bool' },
    only_ancient_segments => { type => 'bool' },
    only_expunge_deletes  => { type => 'bool' },
    op_type               => {
        default => 'index',
        options => [ 'index', 'create' ],
        type    => 'enum'
    },
    order                  => { type => 'number' },
    os                     => { type => 'bool' },
    parent                 => { type => 'string' },
    parent_node            => { type => 'string' },
    parent_task            => { type => 'string' },
    payloads               => { type => 'bool' },
    percent_terms_to_match => { type => 'number' },
    percolate              => { type => 'string' },
    percolate_format       => { type => 'string' },
    percolate_index        => { type => 'string' },
    percolate_preference   => { type => 'string' },
    percolate_routing      => { type => 'list' },
    percolate_type         => { type => 'string' },
    pipeline               => { type => 'string' },
    plugin                 => { type => 'bool' },
    positions              => { type => 'bool' },
    prefer_local           => { type => 'bool' },
    preference             => { type => 'string' },
    pri                    => { type => 'bool' },
    process                => { type => 'bool' },
    q                      => { type => 'string' },
    query                  => { type => 'bool' },
    query_cache            => { type => 'bool' },
    realtime               => { type => 'bool' },
    recovery               => { type => 'bool' },
    recycler               => { type => 'bool' },
    refresh                => {
        default => 'false',
        type    => 'enum',
        options => [ 'true', 'false', 'wait_for' ]
    },
    replication => {
        default => 'sync',
        options => [ 'sync', 'async' ],
        type    => 'enum'
    },
    request           => { type => 'bool' },
    request_cache     => { type => 'bool' },
    retry_on_conflict => { type => 'number' },
    rewrite           => { type => 'bool' },
    routing           => { type => 'string' },
    script            => { type => 'string' },
    script_id         => { type => 'string' },
    scripted_upsert   => { type => 'bool' },
    scroll            => { type => 'duration' },
    scroll_id         => { type => 'string' },
    scroll_size       => { type => 'number' },
    search            => { type => 'bool' },
    search_from       => { type => 'number' },
    search_indices    => { type => 'list' },
    search_scroll     => { type => 'string' },
    search_size       => { type => 'number' },
    search_source     => { type => 'string' },
    search_timeout    => { type => 'duration' },
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
    status          => { type => 'string' },
    stop_words      => { type => 'list' },
    store           => { type => 'bool' },
    suggest_field   => { type => 'string' },
    suggest_mode    => {
        default => 'missing',
        options => [ 'missing', 'popular', 'always' ],
        type    => 'enum'
    },
    suggest_size     => { type => 'number' },
    suggest_text     => { type => 'string' },
    term_statistics  => { type => 'bool' },
    terminate_after  => { type => 'number' },
    text             => { type => 'string' },
    thread_pool      => { type => 'bool' },
    threads          => { type => 'number' },
    timeout          => { type => 'duration' },
    timestamp        => { type => 'datetime' },
    tokenizer        => { type => 'string' },
    track_scores     => { type => 'bool' },
    transport        => { type => 'bool' },
    ts               => { type => 'bool' },
    ttl              => { type => 'duration' },
    type             => { type => 'string' },
    types            => { type => 'list' },
    update_all_types => { type => 'bool' },
    v                => { type => 'bool' },
    verbose          => { type => 'bool' },
    verify           => { type => 'bool' },
    version          => { type => 'number' },
    version_type     => {
        type    => 'enum',
        options => [ 'internal', 'external' ]
    },
    wait_for_active_shards     => { type => 'number' },
    wait_for_completion        => { type => 'bool' },
    wait_for_merge             => { type => 'bool' },
    wait_for_nodes             => { type => 'string' },
    wait_for_relocating_shards => { type => 'number' },
    wait_for_status            => {
        default => undef,
        options => [ 'green', 'yellow', 'red' ],
        type    => 'enum'
    },
    wait_if_ongoing => { type => 'bool' },
    warmer          => { type => 'bool' }
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

#===================================
sub register_qs {
#===================================
    while (@_) {
        my $key = shift;
        die "Query string parameter ($key) already exists"
            if $Params{$key};
        my $handler = shift
            || die "No handler provided for query string parameter ($key)";
        $Params{$key} = $handler;
    }
}
1;

__END__

# ABSTRACT: A utility class for query string parameters in the API

=head1 DESCRIPTION

This class contains a definition of each query string parameter that
can be accepted by actions in the L<API|Search::Elasticsearch::Role::API>.

=head1 EXPORTS

=head2 C<qs_init()>

    use Search::Elasticsearch::Util::API::QS qw(qs_init);
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

=head2 C<register_qs()>

    use Search::Elasticsearch::Util::API::QS qw(register_qs);

    register_qs( foo => { type => 'bool'},...)

Allows plugins to add query string parameter handlers.

