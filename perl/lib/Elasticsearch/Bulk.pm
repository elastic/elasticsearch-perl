package Elasticsearch::Bulk;

use Moo;
with 'Elasticsearch::Role::Bulk', 'Elasticsearch::Role::Is_Sync';
use Elasticsearch::Util qw(parse_params throw);
use Try::Tiny;
use namespace::clean;

#===================================
sub add_action {
#===================================
    my $self      = shift;
    my $buffer    = $self->_buffer;
    my $max_size  = $self->max_size;
    my $max_count = $self->max_count;

    while (@_) {
        my @json = $self->_encode_action( splice( @_, 0, 2 ) );

        push @$buffer, @json;

        my $size = $self->_buffer_size;
        $size += length($_) + 1 for @json;
        $self->_buffer_size($size);

        my $count = $self->_buffer_count( $self->_buffer_count + 1 );

        $self->flush
            if ( $max_size && $size >= $max_size )
            || $max_count && $count >= $max_count;
    }
    return 1;
}

#===================================
sub flush {
#===================================
    my $self = shift;

    return { items => [] }
        unless $self->_buffer_size;

    if ( $self->verbose ) {
        local $| = 1;
        print ".";
    }
    my $buffer  = $self->_buffer;
    my $results = try {
        $self->es->bulk( %{ $self->_bulk_args }, body => $buffer );
    }
    catch {
        my $error = $_;
        $self->clear_buffer
            if $error->is('Request')
            and not $error->is('Unavailable');

        die $error;
    };
    $self->clear_buffer;
    $self->_report( $buffer, $results );
    return defined wantarray ? $results : undef;
}

#===================================
sub reindex {
#===================================
    my ( $self, $params ) = parse_params(@_);
    my $src = $params->{source}
        or throw( 'Param', "Missing required param <source>" );

    my $transform = $self->_doc_transformer($params);

    if ( ref $src eq 'HASH' ) {
        my $scroll = $self->es->scroll_helper(
            es          => $self->es,
            search_type => 'scan',
            size        => 500,
            %$src
        );

        $src = sub {
            $scroll->refill_buffer;
            $scroll->drain_buffer;
        };

        print "Reindexing " . $scroll->total . " docs\n"
            if $self->verbose;
    }

    while ( my @docs = $src->() ) {
        $self->index( grep {$_} map { $transform->($_) } @docs );
    }
    $self->flush;
    return 1;
}

1;

__END__

# ABSTRACT: A helper module for the Bulk API and for reindexing

=head1 SYNOPSIS

    use Elasticsearch;
    use Elasticsearch::Bulk;

    my $es   = Elasticsearch->new;
    my $bulk = Elasticsearch::Bulk->new(
        es      => $es,
        index   => 'my_index',
        type    => 'my_type'
    );

    # Index docs:
    $bulk->index({ id => 1, source => { foo => 'bar' }});
    $bulk->add_action( index => { id => 1, source => { foo=> 'bar' }});

    # Create docs:
    $bulk->create({ id => 1, source => { foo => 'bar' }});
    $bulk->add_action( create => { id => 1, source => { foo=> 'bar' }});
    $bulk->create_docs({ foo => 'bar' })

    # Delete docs:
    $bulk->delete({ id => 1});
    $bulk->add_action( delete => { id => 1 });
    $bulk->delete_ids(1,2,3)

    # Update docs:
    $bulk->update({ id => 1, script => '...' });
    $bulk->add_action( update => { id => 1, script => '...' });

    # Manual flush
    $bulk->flush

    # Reindex docs:
    $bulk = Elasticsearch::Bulk->new(
        es      => $es,
        index   => 'new_index',
        verbose => 1
    );

    $bulk->reindex( source => { index => 'old_index' });

=head1 DESCRIPTION

This module provides a wrapper for the L<Elasticsearch::Client::Direct/bulk()>
method which makes it easier to run multiple create, index, update or delete
actions in a single request. It also provides a simple interface
for L<reindexing documents|/REINDEXING DOCUMENTS>.

The L<Elasticsearch::Bulk> module acts as a queue, buffering up actions
until it reaches a maximum count of actions, or a maximum size of JSON request
body, at which point it issues a C<bulk()> request.

Once you have finished adding actions, call L</flush()> to force the final
C<bulk()> request on the items left in the queue.

This class does L<Elasticsearch::Role::Bulk> and
L<Elasticsearch::Role::Is_Sync>.

=head1 CREATING A NEW INSTANCE

=head2 C<new()>

    $bulk = Elasticsearch::Bulk->new(
        es          => $es,                 # required

        index       => 'default_index',     # optional
        type        => 'default_type',      # optional
        %other_bulk_params                  # optional

        max_count   => 1_000,               # optional
        max_size    => 1_000_000,           # optional

        verbose     => 0 | 1,               # optional

        on_success  => sub {...},           # optional
        on_error    => sub {...},           # optional
        on_conflict => sub {...},           # optional


    );

The C<new()> method returns a new C<$bulk> object.  You must pass your
Elasticsearch client as the C<es> argument.

The C<index> and C<type> parameters provide default values for
C<index> and C<type>, which can be overridden in each action.
You can also pass any other values which are accepted
by the L<bulk()|Elasticsearch::Client::Direct/bulk()> method.

See L</flush()> for more information about the other parameters.

=head1 FLUSHING THE BUFFER

=head2 C<flush()>

    $result = $bulk->flush;

The C<flush()> method sends all buffered actions to Elasticsearch using
a L<bulk()|Elasticsearch::Client::Direct/bulk()> request.

=head2 Auto-flushing

An automatic L</flush()> is triggered whenever the C<max_count> or C<max_size>
threshold is breached.  This causes all actions in the buffer to be
sent to Elasticsearch.

=over

=item * C<max_count>

The maximum number of actions to allow before triggering a L</flush()>.
This can be disabled by setting C<max_count> to C<0>. Defaults to
C<1,000>.

=item * C<max_size>

The maximum size of JSON request body to allow before triggering a
L</flush()>.  This can be disabled by setting C<max_size> to C<0>.  Defaults
to C<1_000,000> bytes.

=back

=head2 Errors when flushing

There are three levels of error which can be thrown when L</flush()>
is called, either manually or automatically.

=over

=item * Temporary Elasticsearch errors

For instance, a C<NoNodes> error which indicates that your cluster is down.
These errors do not clear the buffer, as they can be retried later on.

=item * Request errors

For instance, if one of your actions is malformed (eg you are missing
a required parameter like C<index>) then the whole L</flush()> request is
aborted and the buffer is cleared of all actions.

=item * Action errors

Individual actions may fail. For instance, a C<create> action will fail
if a document with the same C<index>, C<type> and C<id> already exists.
These action errors are reported via L<callbacks|/Using callbacks>.

=back

=head2 Using callbacks

By default, any I<Action errors> (see above) cause warnings to be
written to C<STDERR>.  However, you can use the C<on_error>, C<on_conflict>
and C<on_success> callbacks for more fine-grained control.

All callbacks receive the following arguments:

=over

=item C<$action>

The name of the action, ie C<index>, C<create>, C<update> or C<delete>.

=item C<$response>

The response that Elasticsearch returned for this action.

=item C<$i>

The index of the action, ie the first action in the flush request
will have C<$i> set to C<0>, the second will have C<$i> set to C<1> etc.

=back

=head3 C<on_success>

    $bulk = Elasticsearch->new(
        es          => $es,
        on_success  => sub {
            my ($action,$response,$i) = @_;
            # do something
        },
    );

The C<on_success> callback is called for every action that has a successful
response.

=head3 C<on_conflict>

    $bulk = Elasticsearch::Bulk->new(
        es           => $es,
        on_conflict  => sub {
            my ($action,$response,$i,$version) = @_;
            # do something
        },
    );

The C<on_conflict> callback is called for actions that have triggered
a C<Conflict> error, eg trying to C<create> a document which already
exists.  The C<$version> argument will contain the version number
of the document currently stored in Elasticsearch (if found).

=head3 C<on_error>

    $bulk = Elasticsearch::Bulk->new(
        es        => $es,
        on_error  => sub {
            my ($action,$response,$i) = @_;
            # do something
        },
    );

The C<on_error> callback is called for any error (unless the C<on_conflict>)
callback has already been called).

=head2 Disabling callbacks and autoflush

If you want to be in control of flushing, and you just want to receive
the raw response that Elasticsearch sends instead of using callbacks,
then you can do so as follows:

    $bulk = Elasticsearch::Bulk->new(
        es          => $es,
        max_count   => 0,
        max_size    => 0,
        on_error    => undef
    );

    $bulk->add_actions(....);
    $response = $bulk->flush;

=head1 CREATE, INDEX, UPDATE, DELETE

=head2 C<add_action()>

    $bulk->add_action(
        create => { ...params... },
        index  => { ...params... },
        update => { ...params... },
        delete => { ...params... }
    );

The C<add_action()> method allows you to add multiple C<create>, C<index>,
C<update> and C<delete> actions to the queue. The first value is the action
type, and the second value is the parameters that describe that action.
See the individual helper methods below for details.

B<Note:> Parameters like C<index> or C<type> can be specified as C<index> or as
C<_index>, so the following two lines are equivalent:

    index => { index  => 'index', type  => 'type', id  => 1, source  => {...}},
    index => { _index => 'index', _type => 'type', _id => 1, _source => {...}},

B<Note:> The C<index> and C<type> parameters can be specified in the
params for any action, but if not specified, will default to the C<index>
and C<type> values specified in L</new()>.  These are required parameters:
they must be specified either in L</new()> or in every action.

=head2 C<create()>

    $bulk->create(
        { index => 'custom_index',         source => { doc body }},
        { type  => 'custom_type', id => 1, source => { doc body }},
        ...
    );

The C<create()> helper method allows you to add multiple C<create> actions.
It accepts the same parameters as L<Elasticsearch::Client::Direct/create()>
except that the document body should be passed as the C<source> or C<_source>
parameter, instead of as C<body>.

=head2 C<create_docs()>

    $bulk->create_docs(
        { doc body },
        { doc body },
        ...
    );

The C<create_docs()> helper is a shorter form of L</create()> which can be used
when you are using the default C<index> and C<type> as set in L</new()>
and you are not specifying a custom C<id> per document.  In this case,
you can just pass the individual document bodies.

=head2 C<index()>

    $bulk->index(
        { index => 'custom_index',         source => { doc body }},
        { type  => 'custom_type', id => 1, source => { doc body }},
        ...
    );

The C<index()> helper method allows you to add multiple C<index> actions.
It accepts the same parameters as L<Elasticsearch::Client::Direct/index()>
except that the document body should be passed as the C<source> or C<_source>
parameter, instead of as C<body>.

=head2 C<delete()>

    $bulk->delete(
        { index => 'custom_index', id => 1},
        { type  => 'custom_type',  id => 2},
        ...
    );

The C<delete()> helper method allows you to add multiple C<delete> actions.
It accepts the same parameters as L<Elasticsearch::Client::Direct/delete()>.

=head2 C<delete_ids()>

    $bulk->delete_ids(1,2,3...)

The C<delete_ids()> helper method can be used when all of the documents you
want to delete have the default C<index> and C<type> as set in L</new()>.
In this case, all you have to do is to pass in a list of IDs.

=head2 C<update()>

    $bulk->update(
        { id            => 1,
          doc           => { partial doc },
          doc_as_upsert => 1
        },
        { id            => 2,
          lang          => 'mvel',
          script        => '_ctx.source.counter+=incr',
          params        => { incr => 1},
          upsert        => { upsert doc }
        },
        ...
    );


The C<update()> helper method allows you to add multiple C<update> actions.
It accepts the same parameters as L<Elasticsearch::Client::Direct/update()>.
An update can either use a I<partial doc> which gets merged with an existing
doc (example 1 above), or can use a C<script> to update an existing doc
(example 2 above).

=head1 REINDEXING DOCUMENTS

A common use case for bulk indexing is to reindex a whole index when
changing the type mappings or analysis chain. This typically
combines bulk indexing with L<scrolled searches|Elasticsearch::Scroll>:
the scrolled search pulls all of the data from the source index, and
the bulk indexer indexes the data into the new index.

=head2 C<reindex()>

    $bulk->reindex(
        source       => $source,                # required
        transform    => \&transform,            # optional
        version_type => 'external|internal',    # optional
    );

The C<reindex()> method requires a C<$source> parameter, which provides
the source for the documents which are to be reindexed.

=head2 Reindexing from another index

If the C<source> argument is a HASH ref, then the hash is passed to
L<Elasticsearch::Scroll/new()> to create a new scrolled search.

    $bulk = Elasticsearch::Bulk->new(
        index   => 'new_index',
        verbose => 1
    );

    $bulk->reindex(
        source  => {
            index       => 'old_index',
            size        => 500,         # default
            search_type => 'scan'       # default
        }
    );

If a default C<index> or C<type> has been specified in the call to
L</new()>, then it will replace the C<index> and C<type> values for
the docs returned from the scrolled search. In the example above,
all docs will be retrieved from C<"old_index"> and will be bulk indexed
into C<"new_index">.

=head2 Reindexing from a generic source

The C<source> parameter also accepts a coderef or an anonymous sub,
which should return one or more new documents every time it is executed.
This allows you to pass any iterator, wrapped in an anonymous sub:

    my $iter = get_iterator_from_somewhere();

    $bulk->reindex(
        source => sub { $iter->next }
    );

=head2 Transforming docs on the fly

The C<transform> parameter allows you to change documents on the fly,
using a callback.  The callback receives the document as the only argument,
and should return the updated document, or C<undef> if the document should
not be indexed:

    $bulk->reindex(
        source      => { index => 'old_index' },
        transform   => sub {
            my $doc = shift;

            # don't index doc marked as valid:false
            return undef unless $doc->{_source}{valid};

            # convert $tag to @tags
            $doc->{_source}{tags} = [ delete $doc->{_source}{tag}];
            return $doc
        }
    );

=head2 Reindexing from another cluster

By default, L</reindex()> expects the source and destination indices
to be in the same cluster. To pull data from one cluster and index it into
another, you can use two separate C<$es> objects:

    $es_local  = Elasticsearch->new( nodes => 'localhost:9200' );
    $es_remote = Elasticsearch->new( nodes => 'search1:9200' );

    Elasticsearch::Bulk->new(
        es => $es_local,
        verbose => 1
    )
    -> reindex( es => $es_remote );

=head2 Parents and routing

If you are using parent-child relationships or custom C<routing> values,
and you want to preserve these when you reindex your documents, then
you will need to request these values specifically, as follows:

    $bulk->reindex(
        source => {
            index   => 'old_index',
            fields  => ['_source','_parent','_routing']
        }
    );

=head2 Working with version numbers

Every document in Elasticsearch has a current C<version> number, which
is used for L<optimistic concurrency control|http://en.wikipedia.org/wiki/Optimistic_concurrency_control>,
that is, to ensure that you don't overwrite changes that have been made
by another process.

All CRUD operations accept a C<version> parameter and a C<version_type>
parameter which tells Elasticsearch that the change should only be made
if the current document corresponds to these parameters. The
C<version_type> parameter can have the following values:

=over

=item * C<internal>

Use Elasticsearch version numbers.  Documents are only changed if the
document in Elasticsearch has the B<same> C<version> number that is
specified in the CRUD operation. After the change, the new
version number is C<version+1>.

=item * C<external>

Use an external versioning system, such as timestamps or version numbers
from an external database.  Documents are only changed if the document
in Elasticsearch has a B<lower> C<version> number than the one
specified in the CRUD operation. After the change, the new version
number is C<version>.

=back

If you would like to reindex documents from one index to another, preserving
the C<version> numbers from the original index, then you need the following:

    $bulk->reindex(
        source => {
            index   => 'old_index',
            version => 1,               # retrieve version numbers in search
        },
        version_type => 'external'      # use these "external" version numbers
    );

