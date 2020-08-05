# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Client::5_0::Direct::Ingest;

use Moo;
with 'Search::Elasticsearch::Client::5_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('ingest');

1;

__END__

# ABSTRACT: A client for accessing the Ingest API

=head1 DESCRIPTION

This module provides methods to access the Ingest API, such as creating,
getting, deleting and simulating ingest pipelines.

It does L<Search::Elasticsearch::Role::Client::Direct>.

=head1 METHODS

=head2 C<put_pipeline()>

    $response = $e->ingest->put_pipeline(
        id   => $id,                # required
        body => { pipeline defn }   # required
    );

The C<put_pipeline()> method creates or updates a pipeline with the specified ID.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>

See the L<put pipeline docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/put-pipeline-api.html>
for more information.

=head2 C<get_pipeline()>

    $response = $e->ingest->get_pipeline(
        id   => \@id,               # optional
    );

The C<get_pipeline()> method returns pipelines with the specified IDs (or all pipelines).

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>

See the L<get pipeline docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/get-pipeline-api.html>
for more information.

=head2 C<delete_pipeline()>

    $response = $e->ingest->delete_pipeline(
        id   => $id,                # required
    );

The C<delete_pipeline()> method deletes the pipeline with the specified ID.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<master_timeout>,
    C<timeout>

See the L<delete pipeline docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/delete-pipeline-api.html>
for more information.

=head2 C<simulate()>

    $response = $e->ingest->put_pipeline(
        id   => $id,                # optional
        body => { simulate args }   # required
    );

The C<simulate()> method executes the pipeline specified by ID or inline in the body
against the docs provided in the body and provides debugging output of the execution
process.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<verbose>

See the L<simulate pipeline docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/simulate-pipeline-api.html>
for more information.


=head2 C<processor_grok>

    $response = $e->inges->processor_grok()

Retrieves the configured patterns associated with the Grok processor.

Query string parameters:
    C<error_trace>,
    C<human>

See the L<grok processor docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/grok-processor.html>
for more information.

