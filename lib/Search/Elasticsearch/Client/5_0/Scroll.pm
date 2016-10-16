package Search::Elasticsearch::Client::5_0::Scroll;

use Moo;
use Search::Elasticsearch::Util qw(parse_params throw);
use namespace::clean;

has '_buffer' => ( is => 'ro' );

with 'Search::Elasticsearch::Role::Is_Sync',
    'Search::Elasticsearch::Client::5_0::Role::Scroll';

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my $es = delete $params->{es};
    my $scroll = $params->{scroll} ||= '1m';

    throw( 'Param',
        'The (scroll_in_body) parameter has been replaced by (scroll_in_qs)' )
        if exists $params->{scroll_in_body};

    my $scroll_in_qs = delete $params->{scroll_in_qs};
    my $results      = $es->search($params);

    my $total = $results->{hits}{total};

    return {
        es           => $es,
        scroll       => $scroll,
        scroll_in_qs => $scroll_in_qs,
        aggregations => $results->{aggregations},
        facets       => $results->{facets},
        suggest      => $results->{suggest},
        took         => $results->{took},
        total_took   => $results->{took},
        total        => $total,
        max_score    => $results->{hits}{max_score},
        _buffer      => $results->{hits}{hits},
        $total
        ? ( _scroll_id => $results->{_scroll_id} )
        : ( is_finished => 1 )
    };
}

#===================================
sub next {
#===================================
    my ( $self, $n ) = @_;
    $n ||= 1;
    while ( $self->_has_scroll_id and $self->buffer_size < $n ) {
        $self->refill_buffer;
    }
    my @return = splice( @{ $self->_buffer }, 0, $n );
    $self->finish if @return < $n;
    return wantarray ? @return : $return[-1];
}

#===================================
sub drain_buffer {
#===================================
    my $self = shift;
    return splice( @{ $self->_buffer } );
}

#===================================
sub buffer_size { 0 + @{ shift->_buffer } }
#===================================

#===================================
sub refill_buffer {
#===================================
    my $self = shift;

    return 0 if $self->is_finished;

    my $buffer    = $self->_buffer;
    my $scroll_id = $self->_scroll_id
        || return 0 + @$buffer;

    my $results = $self->scroll_request;

    my $hits = $results->{hits}{hits};
    $self->_set_total_took( $self->total_took + $results->{took} );

    if ( @$hits == 0 ) {
        $self->_clear_scroll_id;
    }
    else {
        $self->_set__scroll_id( $results->{_scroll_id} );
        push @$buffer, @$hits;
    }
    $self->finish if @$buffer == 0;
    return 0 + @$buffer;
}

#===================================
sub finish {
#===================================
    my $self = shift;
    return if $self->is_finished || $self->_pid != $$;

    $self->_set_is_finished(1);
    @{ $self->_buffer } = ();

    my $scroll_id = $self->_scroll_id or return;
    $self->_clear_scroll_id;

    my %args
        = $self->scroll_in_qs
        ? ( scroll_id => $scroll_id )
        : ( body => $scroll_id );
    eval { $self->es->clear_scroll(%args) };
    return 1;
}

1;

__END__

# ABSTRACT: A helper module for scrolled searches

=head1 SYNOPSIS

    use Search::Elasticsearch;

    my $es     = Search::Elasticsearch->new;

    my $scroll = $es->scroll_helper(
        index       => 'my_index',
        body => {
            query   => {...},
            size    => 1000,
            sort    => '_doc'
        }
    );

    say "Total hits: ". $scroll->total;

    while (my $doc = $scroll->next) {
        # do something
    }

=head1 DESCRIPTION

A I<scrolled search> is a search that allows you to keep pulling results
until there are no more matching results, much like a cursor in an SQL
database.

Unlike paginating through results (with the C<from> parameter in
L<search()|Search::Elasticsearch::Client::5_0::Direct/search()>),
scrolled searches take a snapshot of the current state of the index. Even
if you keep adding new documents to the index or updating existing documents,
a scrolled search will only see the index as it was when the search began.

This module is a helper utility that wraps the functionality of the
L<search()|Search::Elasticsearch::Client::5_0::Direct/search()> and
L<scroll()|Search::Elasticsearch::Client::5_0::Direct/scroll()> methods to make
them easier to use.

This class does L<Search::Elasticsearch::Client::5_0::Role::Scroll> and
L<Search::Elasticsearch::Role::Is_Sync>.


=head1 USE CASES

There are two primary use cases:

=head2 Pulling enough results

Perhaps you want to group your results by some field, and you don't know
exactly how many results you will need in order to return 10 grouped
results.  With a scrolled search you can keep pulling more results
until you have enough.  For instance, you can search emails in a mailing
list, and return results grouped by C<thread_id>:

    my (%groups,@results);

    my $scroll = $es->scroll_helper(
        index => 'my_emails',
        type  => 'email',
        body  => { query => {... some query ... }}
    );

    my $doc;
    while (@results < 10 and $doc = $scroll->next) {

        my $thread = $doc->{_source}{thread_id};

        unless ($groups{$thread}) {
            $groups{$thread} = [];
            push @results, $groups{$thread};
        }
        push @{$groups{$thread}},$doc;

    }


=head2 Extracting all documents

Often you will want to extract all (or a subset of) documents in an index.
If you want to change your type mappings, you will need to reindex all of your
data. Or perhaps you want to move a subset of the data in one index into
a new dedicated index. In these cases, you don't care about sort
order, you just want to retrieve all documents which match a query, and do
something with them. For instance, to retrieve all the docs for a particular
C<client_id>:

    my $scroll = $es->scroll_helper(
        index       => 'my_index',
        size        => 1000,
        body        => {
            query => {
                match => {
                    client_id => 123
                }
            },
            sort => '_doc'
        }
    );

    while (my $doc = $scroll->next) {
        # do something
    }

Very often the I<something> that you will want to do with these results
involves bulk-indexing them into a new index. The easiest way to
do this is to use the built-in L<Search::Elasticsearch::Client::5_0::Direct/reindex()>
functionality provided by Elasticsearch.

=head1 METHODS

=head2 C<new()>

    use Search::Elasticsearch;

    my $es = Search::Elasticsearch->new(...);
    my $scroll = $es->scroll_helper(
        scroll         => '1m',            # optional
        scroll_in_qs   => 0|1,             # optional
        %search_params
    );

The L<Search::Elasticsearch::Client::5_0::Direct/scroll_helper()> method loads
L<Search::Elasticsearch::Client::5_0::Scroll> class and calls L</new()>,
passing in any arguments.

You can specify a C<scroll> duration (which defaults to C<"1m">) and
C<scroll_in_qs> (which defaults to C<false>). Any other parameters are
passed directly to L<Search::Elasticsearch::Client::5_0::Direct/search()>.

The C<scroll> duration tells Elasticearch how long it should keep the scroll
alive.  B<Note>: this duration doesn't need to be long enough to process
all results, just long enough to process a single B<batch> of results.
The expiry gets renewed for another C<scroll> period every time new
a new batch of results is retrieved from the cluster.

By default, the C<scroll_id> is passed as the C<body> to the
L<scroll|Search::Elasticsearch::Client::5_0::Direct/scroll()> request.
To send it in the query string instead, set C<scroll_in_qs> to a true value,
but be aware: when querying very many indices, the scroll ID can become
too long for intervening proxies.

The C<scroll> request uses C<GET> by default.  To use C<POST> instead,
set L<send_get_body_as|Search::Elasticsearch::Transport/send_get_body_as> to
C<POST>.

=head2 C<next()>

    $doc  = $scroll->next;
    @docs = $scroll->next($num);

The C<next()> method returns the next result, or the next C<$num> results
(pulling more results if required).  If all results have been exhausted,
it returns an empty list.

=head2 C<drain_buffer()>

    @docs = $scroll->drain_buffer;

The C<drain_buffer()> method returns all of the documents currently in the
buffer, without fetching any more from the cluster.

=head2 C<refill_buffer()>

    $total = $scroll->refill_buffer;

The C<refill_buffer()> method fetches the next batch of results from the
cluster, stores them in the buffer, and returns the total number of docs
currently in the buffer.

=head2 C<buffer_size()>

    $total = $scroll->buffer_size;

The C<buffer_size()> method returns the total number of docs currently in
the buffer.

=head2 C<finish()>

    $scroll->finish;

The C<finish()> method clears out the buffer, sets L</is_finished()> to C<true>
and tries to clear the C<scroll_id> on Elasticsearch.  This API is only
supported since v0.90.5, but the call to C<clear_scroll> is wrapped in an
C<eval> so the C<finish()> method can be safely called with any version
of Elasticsearch.

When the C<$scroll> instance goes out of scope, L</finish()> is called
automatically if required.

=head2 C<is_finished()>

    $bool = $scroll->is_finished;

A flag which returns C<true> if all results have been processed or
L</finish()> has been called.

=head1 INFO ACCESSORS

The information from the original search is returned via the following
accessors:

=head2 C<total>

The total number of documents that matched your query.

=head2 C<max_score>

The maximum score of any documents in your query.

=head2 C<aggregations>

Any aggregations that were specified, or C<undef>

=head2 C<facets>

Any facets that were specified, or C<undef>

=head2 C<suggest>

Any suggestions that were specified, or C<undef>

=head2 C<took>

How long the original search took, in milliseconds

=head2 C<took_total>

How long the original search plus all subsequent batches took, in milliseconds.

=head1 SEE ALSO

=over

=item * L<Search::Elasticsearch::Client::5_0::Direct/search()>

=item * L<Search::Elasticsearch::Client::5_0::Direct/scroll()>

=item * L<Search::Elasticsearch::Client::5_0::Direct/reindex()>

=back
