# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Client::7_0::Async::Scroll;

use Moo;
use Search::Elasticsearch::Util qw(parse_params throw);
use Search::Elasticsearch::Async::Util qw(thenable);
use Scalar::Util qw(weaken blessed);
use Promises qw(deferred);
use namespace::clean;

has 'one_at_a_time' => ( is => 'ro' );
has 'on_start'      => ( is => 'ro', clearer => '_clear_on_start' );
has 'on_results'    => ( is => 'ro', clearer => '_clear_on_results' );
has 'on_error'      => ( is => 'lazy', clearer => '_clear_on_error' );
has '_guard'        => ( is => 'rwp', clearer => '_clear__guard' );

with 'Search::Elasticsearch::Role::Is_Async',
    'Search::Elasticsearch::Client::7_0::Role::Scroll';

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $search_params ) = parse_params(@_);

        my %params;
    for (qw(es on_start on_result on_results on_error)) {
        my $val = delete $search_params->{$_};
        next unless defined $val;
        $params{$_} = $val;
    }

    $params{scroll} = $search_params->{scroll} ||= '1m';
    $params{search_params} = $search_params;

    if ( $params{on_result} ) {
        $params{on_results}    = delete $params{on_result};
        $params{one_at_a_time} = 1;
    }
    elsif ( !$params{on_results} ) {
        throw( 'Param', 'Missing required param: on_results or on_result' );
    }
    return \%params;
}

#===================================
sub _build_on_error {
#===================================
    sub { warn "Scroll error: @_"; die @_ }
}

#===================================
sub start {
#===================================
    my $self = shift;
    $self->_set__guard($self);

    $self->es->search( $self->search_params )->then(
        sub {
            $self->_first_results(@_);
        }
        )->then(
        sub {
            $self->_fetch_loop;
        }
        )->catch(
        sub {
            $self->on_error->(@_);
            @_;
        }
        )->finally(
        sub {
            $self->finish;
            $self->_clear__guard;
        }
        );
}

#===================================
sub _first_results {
#===================================
    my ( $self, $results ) = @_;

    my $total = $results->{hits}{total};
    if (ref $total) {
        $total = $total->{value};
    }
    $self->_set_total($total);
    $self->_set_max_score( $results->{hits}{max_score} );
    $self->_set_aggregations( $results->{aggregations} );
    $self->_set_facets( $results->{facets} );
    $self->_set_suggest( $results->{suggest} );
    $self->_set_took( $results->{took} );
    $self->_set_total_took( $results->{took} );

    if ($total) {
        $self->_set__scroll_id( $results->{_scroll_id} );
    }
    else {
        $self->finish;
    }

    $self->on_start && $self->on_start->($self);

    my $hits = $results->{hits}{hits};
    return unless @$hits;
    return $self->_push_results($hits);
}

#===================================
sub _next_results {
#===================================
    my ( $self, $results ) = @_;
    $self->_set__scroll_id( $results->{_scroll_id} );
    $self->_set_total_took( $self->total_took + $results->{took} );

    my $hits = $results->{hits}{hits};
    return $self->finish
        unless @$hits;
    $self->_push_results($hits);
}

#===================================
sub _fetch_loop {
#===================================
    my $self = shift;
    my $d    = deferred;

    my $weak_loop;
    my $loop = sub {
        if ( $self->is_finished ) {
            return $d->resolve;
        }
        $self->scroll_request->then( sub { $self->_next_results(@_) } )
            ->done( $weak_loop, sub { $d->reject(@_) } );
    };
    weaken( $weak_loop = $loop );
    $loop->();
    return $d->promise;
}

#===================================
sub _push_results {
#===================================
    my $self       = shift;
    my $it         = $self->_results_iterator(@_);
    my $on_results = $self->on_results;

    my $deferred = deferred;

    my $weak_process;
    my $process = sub {
        while ( !$self->is_finished ) {
            my @results  = $it->() or last;
            my @response = $on_results->(@results);
            my $promise  = thenable(@response) or next;
            return $promise->done( $weak_process,
                sub { $deferred->reject(@_) } );
        }
        $deferred->resolve;
    };
    weaken( $weak_process = $process );
    $process->();
    return $deferred->promise;
}

#===================================
sub _results_iterator {
#===================================
    my $self    = shift;
    my @results = @{ shift() };

    $self->one_at_a_time
        ? sub { splice @results, 0, 1 }
        : sub { splice @results };
}

#===================================
sub finish {
#===================================
    my $self = shift;
    $self->_set_is_finished(1);

    my $scroll_id = $self->_scroll_id;
    $self->_clear_scroll_id;

    if ( !$scroll_id || $self->_pid != $$ ) {
        my $d = deferred;
        $d->resolve();
        return $d->promise;
    }

    my %args = ( body => { scroll_id => $scroll_id } );

    $self->es->clear_scroll(%args)->then(
        sub {
            $self->_clear_on_start;
            $self->_clear_on_results;
            $self->_clear_on_error;
        },
        sub { }
    );
}

1;

# ABSTRACT: A helper module for scrolled searches

=head1 SYNOPSIS

    use Search::Elasticsearch::Async;

    my $es = Search::Elasticsearch::Async->new;

    my $scroll = $es->scroll_helper
        index       => 'my_index',
        body => {
            size    => 1000,
            sort    => '_doc',
            query   => {...}
        },
        on_start    => \&on_start,
        on_result   => \&on_result,
      | on_results  => \&on_results,
        on_error    => \&on_error
    );

    $scroll->start->then( sub {say "Done"}, sub { warn @_ } );

    sub on_start {
        my $scroll = shift;
        say "Total hits: ". $scroll->total;
    }

    sub on_result {
        my $doc = shift;
        do_something($doc);
    }

    sub on_results {
        for my $doc (@_) {
            do_something($doc)
        }
    }

    sub on_error {
        my $error = shift;
        warn "$error";
    }

=head1 DESCRIPTION

A I<scrolled search> is a search that allows you to keep pulling results
until there are no more matching results, much like a cursor in an SQL
database.

Unlike paginating through results (with the C<from> parameter in
L<search()|Search::Elasticsearch::Client::7_0::Direct/search()>),
scrolled searches take a snapshot of the current state of the index. Even
if you keep adding new documents to the index or updating existing documents,
a scrolled search will only see the index as it was when the search began.

This module is a helper utility that wraps the functionality of the
L<search()|Search::Elasticsearch::Client::7_0::Direct/search()> and
L<scroll()|Search::Elasticsearch::Client::7_0::Direct/scroll()> methods to make
them easier to use.

This class does L<Search::Elasticsearch::Client::7_0::Role::Scroll> and
L<Search::Elasticsearch::Role::Is_Async>.

=head1 USE CASES

There are two primary use cases:

=head2 Pulling enough results

Perhaps you want to group your results by some field, and you don't know
exactly how many results you will need in order to return 10 grouped
results.  With a scrolled search you can keep pulling more results
until you have enough.  For instance, you can search emails in a mailing
list, and return results grouped by C<thread_id>:

    use Promises qw(deferred);

    sub find_email_threads {
        my (%groups,@results,$scroll);

        my $d = deferred;

        $scroll = $es->scroll_helper(
            index     => 'my_emails',
            type      => 'email',
            body      => { query => {... some query ... }},
            on_result => sub {
                my $doc = shift;
                my $thread = $doc->{_source}{thread_id};
                unless ($groups{$thread}) {
                    $groups{$thread} = [];
                    push @results, $groups{$thread};
                }
                push @{$groups{$thread}},$doc;

                # stop collecting if we have 10 results
                if (@results == 10) {
                    $scroll->finish;
                }
            }
        );

        $scroll->start->then(
            # resolve with results if completed successfully
            sub { $d->resolve(@results) },

            # reject with error if failed
            sub { $d->reject(@_) }
        );

        return $d->promise;
    }

=head2 Extracting all documents

Often you will want to extract all (or a subset of) documents in an index.
If you want to change your type mappings, you will need to reindex all of your
data. Or perhaps you want to move a subset of the data in one index into
a new dedicated index. In these cases, you don't care about sort
order, you just want to retrieve all documents which match a query, and do
something with them. For instance, to retrieve all the docs for a particular
C<client_id>:

    $es->scroll_helper(
        index       => 'my_index',
        size        => 1000,
        body        => {
            query => {
                match => {
                    client_id => 123
                }
            },
            sort => '_doc'
        },
        on_result => sub { do_something(@_) }
    )->start;

Very often the I<something> that you will want to do with these results
involves bulk-indexing them into a new index. The easiest way to
do this is to use the built-in L<Search::Elasticsearch::Client::7_0::Direct/reindex()>
functionality provided by Elasticsearch.

=head1 METHODS

=head2 C<new()>

    use Search::Elasticsearch::Async;

    my $es = Search::Elasticsearch::Async->new(...);
    my $scroll = $es->scroll_helper(
        scroll             => '1m',            # optional

        on_result          => sub {...}        # required
      | on_results         => sub {...}        # required

        on_start           => sub {...}        # optional
        on_error           => sub {...}        # optional
        %search_params,
    );
    $scroll->start;

The L<Search::Elasticsearch::Client::7_0::Direct/scroll_helper()> method loads
L<Search::Elasticsearch::Client::7_0::Async::Scroll> class and calls L</new()>,
passing in any arguments.

You can specify a C<scroll> duration (which defaults to C<"1m">).
Any other parameters are passed directly to L<Search::Elasticsearch::Client::7_0::Direct/search()>.

The C<scroll> duration tells Elasticearch how long it should keep the scroll
alive.  B<Note>: this duration doesn't need to be long enough to process
all results, just long enough to process a single B<batch> of results.
The expiry gets renewed for another C<scroll> period every time new
a new batch of results is retrieved from the cluster.

By default, the C<scroll_id> is passed as the C<body> to the
L<scroll|Search::Elasticsearch::Client::7_0::Direct/scroll()> request.

The C<scroll> request uses C<GET> by default.  To use C<POST> instead,
set L<send_get_body_as|Search::Elasticsearch::Transport/send_get_body_as> to
C<POST>.

=head3 Callbacks

You must specify either an C<on_result> callback or an C<on_results> callback.

=head4 C<on_result> and C<on_results>

The C<on_result> callback is called once for every result that is received.

    sub on_result {
        my $doc = shift;
        do_something($doc);
    }

Alternatively, you can specify an C<on_results> callback which is called
once for every set of results returned by Elasticsearch:

    sub on_results {
        for my $doc (@_) {
            do_something($doc)
        }
    }

If either C<on_result> or C<on_results> returns a new L<Promise>, processing
of further results will be paused until the promise has been rejected or
resolved.

=head4 C<on_start>

The C<on_start> callback is called after the first request has completed,
at which stage the properties like C<total()>, C<aggregations()>, etc
will have been populated.

=head4 C<on_error>

The C<on_error> callback is called if any error occurs.  The default
implementation warns about the error, and rethrows it.

    sub on_error { warn "Scroll error: @_"; die @_ }

If you wish to handle (and surpress) certain errors, then don't call C<die()>,
eg:

    sub on_error {
        my $error = shift;
        if ($error =~/SomeCatchableError/) {
            # do something to handle error
        }
        else {
            # rethrow error
            die $error;
        }
    }

=head2 C<start()>

    $scroll->start
           ->then( \&success, \&failure );

The C<start()> method starts the scroll and returns a L<Promise> which
will be resolved when the scroll completes (or L</finish()> is called),
or rejected if any errors remain unhandled.

=head2 C<finish()>

    $scroll->finish;

The C<finish()> method clears out the buffer, sets L</is_finished()> to C<true>
and tries to clear the C<scroll_id> on Elasticsearch.  This API is only
supported since v0.90.6, but the call to C<clear_scroll> is wrapped in an
C<eval> so the C<finish()> method can be safely called with any version
of Elasticsearch.

When the C<$scroll> instance goes out of scope, L</finish()> is called
automatically if required.

=head2 C<is_finished()>

    $bool = $scroll->is_finished;

A flag which returns C<true> if all results have been processed or
L</finish()> has been called.

=head1 INFO ACCESSORS

The information from the original search is returned via the accessors
below.  These values can be accessed in the C<on_start> callback:

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
This value can only be checked once the scroll has completed.

=head1 SEE ALSO

=over

=item * L<Search::Elasticsearch::Client::7_0::Direct/search()>

=item * L<Search::Elasticsearch::Client::7_0::Direct/scroll()>

=back
