package Elasticsearch::Util::API::QS;

use strict;
use warnings;

use Sub::Exporter -setup => { exports => ['qs_init'] };

our %Handler = (
    string => sub {"$_[0]"},
    list   => sub {
        ref $_[0]
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
    all => {
        desc => 'Return all available information',
        type => 'bool'
    },
    analyze_wildcard => {
        desc => 'Specify whether wildcards and prefix queries in the query '
            . 'string query should be analyzed (default: false)',
        type => 'bool'
    },
    analyzer => {
        desc => 'Which analyzer to use as the default',
        type => 'string'
    },
    boost_terms => {
        desc => 'The boost factor',
        type => 'number'
    },
    clear => {
        desc => 'Reset the default settings',
        type => 'bool'
    },
    completion => {
        desc => 'Return information about the completion suggester',
        type => 'bool'
    },
    completion_fields => {
        desc => 'A comma-separated list of fields'
            . ' to return in the completion suggester response',
        type => 'list'
    },
    consistency => {
        desc    => 'Explicit write consistency setting for the operation',
        options => [ 'one', 'quorum', 'all' ],
        type    => 'enum'
    },
    default_operator => {
        default => 'OR',
        desc    => 'The default operator for query string query (AND or OR)',
        options => [ 'AND', 'OR' ],
        type    => 'enum'
    },
    delay => {
        desc => 'Set the delay for the operation (default: 1s)',
        type => 'duration'
    },
    df => {
        desc => 'The default field for query string query (default: _all)',
        type => 'string'
    },
    docs => {
        desc => 'Return information about indexed and deleted documents',
        type => 'bool'
    },
    dry_run => {
        desc => 'Simulate the operation only and return the resulting state',
        type => 'bool'
    },
    exit => {
        desc => 'Exit the JVM as well (default: true)',
        type => 'bool'
    },
    explain => {
        desc => 'Return detailed information about the error',
        type => 'bool'
    },
    field => {
        desc => 'Use the analyzer configured for this field '
            . '(instead of passing the analyzer name)',
        type => 'string'
    },
    fielddata => {
        desc => 'Return information about field data',
        type => 'bool'
    },
    fielddata_fields => {
        desc => 'A comma-separated list of fields'
            . ' to return in the fielddata response',
        type => 'list'
    },
    fields => {
        desc => 'A comma-separated list of fields'
            . ' to return in the response',
        type => 'list'
    },
    filter => {
        desc => 'Clear filter caches',
        type => 'bool'
    },
    filter_blocks => {
        desc => 'Do not return information about blocks',
        type => 'bool'
    },
    filter_cache => {
        desc => 'Return information about filter cache',
        type => 'bool'
    },
    filter_index_templates => {
        desc => 'Do not return information about index templates',
        type => 'bool'
    },
    filter_indices => {
        desc => 'Limit returned metadata information to specific indices',
        type => 'list'
    },
    filter_keys => {
        desc => 'A comma-separated list of keys to clear'
            . ' when using the `filter_cache` parameter (default: all)',
        type => 'bool'
    },
    filter_metadata => {
        desc => 'Don\'t return cluster state metadata (default: false)',
        type => 'bool'
    },
    filter_nodes => {
        desc => 'Do not return information about nodes',
        type => 'bool'
    },
    filter_routing_table => {
        desc => 'Do not return information about shard allocation'
            . ' (`routing_table` and `routing_nodes`)',
        type => 'bool'
    },
    filters => {
        desc => 'A comma-separated list of filters to use for the analysis',
        type => 'list'
    },
    flush => {
        desc => 'Specify whether the index should be flushed'
            . ' after performing the operation (default: true)',
        type => 'bool'
    },
    force => {
        desc => 'TODO: ?',
        type => 'bool'
    },
    format => {
        default => 'detailed',
        desc    => 'Format of the output',
        options => [ 'detailed', 'text' ],
        type    => 'enum'
    },
    from => {
        desc => 'Starting offset (default: 0)',
        type => 'number'
    },
    fs => {
        desc => 'Return information about the filesystem',
        type => 'bool'
    },
    full => {
        desc => 'TODO: ?',
        type => 'bool'
    },
    get => {
        desc => 'Return information about get operations',
        type => 'bool'
    },
    groups => {
        desc => 'A comma-separated list of search groups'
            . ' for `search` statistics',
        type => 'bool'
    },
    http => {
        desc => 'Return information about HTTP',
        type => 'bool'
    },
    id => {
        desc => 'The cache_id of the filter to be cleared',
        type => 'string'
    },
    id_cache => {
        desc => 'Return information about ID cache',
        type => 'bool'
    },
    ignore_conflicts => {
        desc => 'Specify whether to ignore conflicts while updating'
            . ' the mapping (default: false)',
        type => 'bool'
    },
    ignore_indices => {
        default => 'none',
        desc    => 'When performed on multiple indices,'
            . ' allows to ignore `missing` ones',
        options => [ 'none', 'missing' ],
        type    => 'enum'
    },
    ignore => {
        type => 'list',
        desc => 'Specify one or more HTTP error response codes to supress',
    },
    index => {
        desc => 'A comma-separated list of index names to filter aliases',
        type => 'list'
    },
    indexing => {
        desc => 'Return information about indexing operations',
        type => 'bool'
    },
    indices => {
        desc => 'Return information about indices',
        type => 'bool'
    },
    indices_boost => {
        desc => 'Comma-separated list of index boosts',
        type => 'list'
    },
    interval => {
        desc => 'The interval for the second sampling of threads',
        type => 'duration'
    },
    jvm => {
        desc => 'Return information about the JVM',
        type => 'bool'
    },
    lang => {
        desc => 'The script language (default: mvel)',
        type => 'string'
    },
    lenient => {
        desc => 'Specify whether format-based query failures'
            . ' (such as providing text to a numeric field) should be ignored',
        type => 'bool'
    },
    level => {
        default => 'cluster',
        desc    => 'Specify the level of detail for returned information',
        options => [ 'cluster', 'indices', 'shards' ],
        type    => 'enum'
    },
    local => {
        desc => 'Return local information, do not retrieve'
            . ' the state from master node (default: false)',
        type => 'bool'
    },
    lowercase_expanded_terms => {
        desc => 'Specify whether query terms should be lowercased',
        type => 'bool'
    },
    master_timeout => {
        desc => 'Explicit operation timeout for connection to master node',
        type => 'duration'
    },
    max_doc_freq => {
        desc => 'The word occurrence frequency as count:'
            . ' words with higher occurrence in the corpus will be ignored',
        type => 'number'
    },
    max_num_segments => {
        desc => 'The number of segments the index should'
            . ' be merged into (default: dynamic)',
        type => 'number'
    },
    max_query_terms => {
        desc => 'The maximum query terms to be included'
            . ' in the generated query',
        type => 'number'
    },
    max_word_len => {
        desc => 'The minimum length of the word:'
            . ' longer words will be ignored',
        type => 'number'
    },
    merge => {
        desc => 'Return information about merge operations',
        type => 'bool'
    },
    min_doc_freq => {
        desc => 'The word occurrence frequency as count:'
            . ' words with lower occurrence in the corpus will be ignored',
        type => 'number'
    },
    min_score => {
        desc => 'Include only documents with a specific'
            . ' `_score` value in the result',
        type => 'number'
    },
    min_term_freq => {
        desc => 'The term frequency as percent: terms with'
            . ' lower occurence in the source document will be ignored',
        type => 'number'
    },
    min_word_len => {
        desc => 'The minimum length of the word:'
            . ' shorter words will be ignored',
        type => 'number'
    },
    mlt_fields => {
        desc => 'Specific fields to perform the query against',
        type => 'list'
    },
    name => {
        desc => 'A comma-separated list of alias names to return',
        type => 'list'
    },
    network => {
        desc => 'Return information about network',
        type => 'bool'
    },
    only_expunge_deletes => {
        desc => 'Specify whether the operation should only'
            . ' expunge deleted documents',
        type => 'bool'
    },
    op_type => {
        default => 'index',
        desc    => 'Explicit operation type',
        options => [ 'index', 'create' ],
        type    => 'enum'
    },
    order => {
        desc => 'The order for this template when merging multiple'
            . ' matching ones (higher numbers are merged later,'
            . ' overriding the lower numbers)',
        type => 'number'
    },
    os => {
        desc => 'Return information about the operating system',
        type => 'bool'
    },
    parent => {
        desc => 'ID of the parent document',
        type => 'string'
    },
    percent_terms_to_match => {
        desc => 'How many terms have to match in order to consider'
            . ' the document a match (default: 0.3)',
        type => 'number'
    },
    percolate => {
        desc => 'Perform percolation during the operation;'
            . ' use specific registered query name, attribute, or wildcard',
        type => 'string'
    },
    plugin => {
        desc => 'Return information about plugins',
        type => 'bool'
    },
    prefer_local => {
        desc => 'With `true`, specify that a local shard should'
            . ' be used if available, with `false`,'
            . ' use a random shard (default: true)',
        type => 'bool'
    },
    preference => {
        desc => 'Specify the node or shard the operation should'
            . ' be performed on (default: random)',
        type => 'string'
    },
    process => {
        desc => 'Return information about the Elasticsearch process',
        type => 'bool'
    },
    q => {
        desc => 'Query in the Lucene query string syntax',
        type => 'string'
    },
    realtime => {
        desc =>
            '"Specify whether to perform the operation in realtime or search mode"',
        type => 'bool'
    },
    recovery => {
        desc => 'Return information about shard recovery',
        type => 'bool'
    },
    recycler => {
        desc => 'Clear the recycler cache',
        type => 'bool'
    },
    refresh => {
        desc => 'Refresh the shard before/after performing the operation',
        type => 'bool'
    },
    replication => {
        default => 'sync',
        desc    => 'Specific replication type',
        options => [ 'sync', 'async' ],
        type    => 'enum'
    },
    retry_on_conflict => {
        desc => 'Specify how many times should the operation'
            . ' be retried when a conflict occurs (default: 0)',
        type => 'number'
    },
    routing => {
        desc => 'Specific routing value',
        type => 'string'
    },
    script => {
        desc => 'The URL-encoded script definition'
            . ' (instead of using request body)',
        type => 'string',
    },
    scroll => {
        desc => 'Specify how long a consistent view of the index'
            . ' should be maintained for scrolled search',
        type => 'duration'
    },
    scroll_id => {
        desc => 'The scroll ID for scrolled search',
        type => 'string'
    },
    search => {
        desc => 'Return information about search operations;'
            . ' use the `groups` parameter to include information'
            . ' for specific search groups',
        type => 'bool'
    },
    search_from => {
        desc => 'The offset from which to return results',
        type => 'number'
    },
    search_indices => {
        desc => 'A comma-separated list of indices to perform the'
            . ' query against (default: the index containing the document)',
        type => 'list'
    },
    search_query_hint => {
        desc => 'The search query hint',
        type => 'string'
    },
    search_scroll => {
        desc => 'A scroll search request definition',
        type => 'string'
    },
    search_size => {
        desc => 'The number of documents to return (default: 10)',
        type => 'number'
    },
    search_source => {
        desc => 'A specific search request definition (instead'
            . ' of using the request body)',
        type => 'string'
    },
    search_type => {
        desc    => 'Search operation type',
        options => [
            'query_then_fetch',     'query_and_fetch',
            'dfs_query_then_fetch', 'dfs_query_and_fetch',
            'count',                'scan'
        ],
        type => 'enum'
    },
    search_types => {
        desc => 'A comma-separated list of types to perform the query'
            . ' against (default: the same type as the document)',
        type => 'list'
    },
    settings => {
        desc => 'Return information about node settings',
        type => 'bool'
    },
    size => {
        desc => 'Number of hits to return (default: 10)',
        type => 'number'
    },
    snapshot => {
        desc => 'TODO: ?',
        type => 'bool'
    },
    snapshots => {
        desc => 'Number of samples of thread stacktrace (default: 10)',
        type => 'number'
    },
    sort => {
        desc => 'A comma-separated list of <field>:<direction> pairs',
        type => 'list'
    },
    source => {
        desc => 'The URL-encoded request definition'
            . ' (instead of using request body)',
        type => 'string'
    },
    _source => {
        type        => "list",
        description => "True or false to return the _source field or not, "
            . "or a list of fields to return"
    },
    _source_exclude => {
        type => "list",
        description =>
            "A list of fields to exclude from the returned _source field"
    },
    _source_include => {
        type => "list",
        description =>
            "A list of fields to extract and return from the _source field"
    },
    stats => {
        desc => 'Specific \'tag\' of the request for'
            . ' logging and statistical purposes',
        type => 'list'
    },
    stop_words => {
        desc => 'A list of stop words to be ignored',
        type => 'list'
    },
    store => {
        desc => 'Return information about the size of the index',
        type => 'bool'
    },
    suggest_field => {
        desc => 'Specify which field to use for suggestions',
        type => 'string'
    },
    suggest_mode => {
        default => 'missing',
        desc    => 'Specify suggest mode',
        options => [ 'missing', 'popular', 'always' ],
        type    => 'enum'
    },
    suggest_size => {
        desc => 'How many suggestions to return in response',
        type => 'number'
    },
    suggest_text => {
        desc =>
            'The source text for which the suggestions should be returned',
        type => 'string'
    },
    text => {
        desc => 'The text on which the analysis should be'
            . ' performed (when request body is not used)',
        type => 'string'
    },
    thread_pool => {
        desc => 'Return information about the thread pool',
        type => 'bool'
    },
    threads => {
        desc => 'Specify the number of threads to provide'
            . ' information for (default: 3)',
        type => 'number'
    },
    timeout => {
        desc => 'Explicit operation timeout',
        type => 'duration'
    },
    timestamp => {
        desc => 'Explicit timestamp for the document',
        type => 'datetime'
    },
    tokenizer => {
        desc => 'The name of the tokenizer to use for the analysis',
        type => 'string'
    },
    transport => {
        desc => 'Return information about transport',
        type => 'bool'
    },
    ttl => {
        desc => 'Time-to-live duration for the document',
        type => 'duration'
    },
    type => {
        desc => 'Default document type for items which don\'t provide one',
        type => 'string'
    },
    version => {
        desc => 'Explicit version number for concurrency control',
        type => 'number'
    },
    version_type => {
        desc    => 'Explicit version number for concurrency control',
        type    => 'enum',
        options => [ 'internal', 'external' ]
    },
    wait_for_active_shards => {
        desc => 'Wait until the specified number of shards is active',
        type => 'number'
    },
    wait_for_merge => {
        desc => 'Specify whether the request should block'
            . ' until the merge process is finished (default: true)',
        type => 'bool'
    },
    wait_for_nodes => {
        desc => 'Wait until the specified number' . ' of nodes is available',
        type => 'number'
    },
    wait_for_relocating_shards => {
        desc => 'Wait until the specified number of'
            . ' relocating shards is finished',
        type => 'number'
    },
    wait_for_status => {
        default => undef,
        desc    => 'Wait until cluster is in a specific state',
        options => [ 'green', 'yellow', 'red' ],
        type    => 'enum'
    },
    warmer => {
        desc => 'Return information about warmers',
        type => 'bool'
    }
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
can be accepeted by actions in the L<API|Elasticsearch::Role::API>.

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
