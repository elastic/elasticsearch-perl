# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

package Search::Elasticsearch::Client::7_0::Bulk;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::Bulk',
    'Search::Elasticsearch::Role::Is_Sync';
use Search::Elasticsearch::Util qw(parse_params throw);
use Try::Tiny;
use namespace::clean;

#===================================
sub add_action {
#===================================
    my $self      = shift;
    my $buffer    = $self->_buffer;
    my $max_size  = $self->max_size;
    my $max_count = $self->max_count;
    my $max_time  = $self->max_time;

    while (@_) {
        my @json = $self->_encode_action( splice( @_, 0, 2 ) );

        push @$buffer, @json;

        my $size = $self->_buffer_size;
        $size += length($_) + 1 for @json;
        $self->_buffer_size($size);

        my $count = $self->_buffer_count( $self->_buffer_count + 1 );

        $self->flush
            if ( $max_size and $size >= $max_size )
            || ( $max_count and $count >= $max_count )
            || ( $max_time  and time >= $self->_last_flush + $max_time );
    }
    return 1;
}

#===================================
sub flush {
#===================================
    my $self = shift;
    $self->_last_flush(time);

    return { items => [] }
        unless $self->_buffer_size;

    if ( $self->verbose ) {
        local $| = 1;
        print ".";
    }
    my $buffer  = $self->_buffer;
    my $results = try {
        my $res = $self->es->bulk( %{ $self->_bulk_args }, body => $buffer );
        $self->clear_buffer;
        return $res;
    }
    catch {
        my $error = $_;
        $self->clear_buffer
            unless $error->is( 'Cxn', 'NoNodes' );

        die $error;
    };
    $self->_report( $buffer, $results );
    return defined wantarray ? $results : undef;
}

1;

__END__

# ABSTRACT: A helper module for the Bulk API

=head1 SYNOPSIS

    use Search::Elasticsearch;

    my $es   = Search::Elasticsearch->new;
    my $bulk = $es->bulk_helper(
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
    $bulk->flush;

=head1 DESCRIPTION

This module provides a wrapper for the L<Search::Elasticsearch::Client::7_0::Direct/bulk()>
method which makes it easier to run multiple create, index, update or delete
actions in a single request.

The L<Search::Elasticsearch::Client::7_0::Bulk> module acts as a queue, buffering up actions
until it reaches a maximum count of actions, or a maximum size of JSON request
body, at which point it issues a C<bulk()> request.

Once you have finished adding actions, call L</flush()> to force the final
C<bulk()> request on the items left in the queue.

This class does L<Search::Elasticsearch::Client::7_0::Role::Bulk> and
L<Search::Elasticsearch::Role::Is_Sync>.

=head1 CREATING A NEW INSTANCE

=head2 C<new()>

    my $bulk = $es->bulk_helper(

        index       => 'default_index',     # optional
        type        => 'default_type',      # optional
        %other_bulk_params                  # optional

        max_count   => 1_000,               # optional
        max_size    => 1_000_000,           # optional
        max_time    => 6,                   # optional

        verbose     => 0 | 1,               # optional

        on_success  => sub {...},           # optional
        on_error    => sub {...},           # optional
        on_conflict => sub {...},           # optional


    );

The C<new()> method returns a new C<$bulk> object.  You must pass your
Search::Elasticsearch client as the C<es> argument.

The C<index> and C<type> parameters provide default values for
C<index> and C<type>, which can be overridden in each action.
You can also pass any other values which are accepted
by the L<bulk()|Search::Elasticsearch::Client::7_0::Direct/bulk()> method.

See L</flush()> for more information about the other parameters.

=head1 FLUSHING THE BUFFER

=head2 C<flush()>

    $result = $bulk->flush;

The C<flush()> method sends all buffered actions to Elasticsearch using
a L<bulk()|Search::Elasticsearch::Client::7_0::Direct/bulk()> request.

=head2 Auto-flushing

An automatic L</flush()> is triggered whenever the C<max_count>, C<max_size>,
or C<max_time> threshold is breached.  This causes all actions in the buffer to be
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

=item * C<max_time>

The maximum number of seconds to wait before triggering a flush.  Defaults
to C<0> seconds, which means that it is disabled.  B<Note:> This timeout
is only triggered when new items are added to the queue, not in the background.

=back

=head2 Errors when flushing

There are two types of error which can be thrown when L</flush()>
is called, either manually or automatically.

=over

=item * Temporary Elasticsearch errors

A C<Cxn> error like a C<NoNodes> error which indicates that your cluster is down.
These errors do not clear the buffer, as they can be retried later on.

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

    my $bulk = $es->bulk_helper(
        on_success  => sub {
            my ($action,$response,$i) = @_;
            # do something
        },
    );

The C<on_success> callback is called for every action that has a successful
response.

=head3 C<on_conflict>

    my $bulk = $es->bulk_helper(
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

    my $bulk = $es->bulk_helper(
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

    my $bulk = $es->bulk_helper(
        max_count   => 0,
        max_size    => 0,
        on_error    => undef
    );

    $bulk->add_action($_) for (@actions);
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

    index => { index  => 'index', type  => 'type', id  => 1, source => {...}},
    index => { _index => 'index', _type => 'type', _id => 1, source => {...}},

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
It accepts the same parameters as L<Search::Elasticsearch::Client::7_0::Direct/create()>
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
It accepts the same parameters as L<Search::Elasticsearch::Client::7_0::Direct/index()>
except that the document body should be passed as the C<source> or C<_source>
parameter, instead of as C<body>.

=head2 C<delete()>

    $bulk->delete(
        { index => 'custom_index', id => 1},
        { type  => 'custom_type',  id => 2},
        ...
    );

The C<delete()> helper method allows you to add multiple C<delete> actions.
It accepts the same parameters as L<Search::Elasticsearch::Client::7_0::Direct/delete()>.

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
          script        => { script }
          upsert        => { upsert doc }
        },
        ...
    );


The C<update()> helper method allows you to add multiple C<update> actions.
It accepts the same parameters as L<Search::Elasticsearch::Client::7_0::Direct/update()>.
An update can either use a I<partial doc> which gets merged with an existing
doc (example 1 above), or can use a C<script> to update an existing doc
(example 2 above). More information on C<script> can be found here:
L<Search::Elasticsearch::Client::7_0::Direct/update()>.

