package Search::Elasticsearch::Plugin::XPack::5_0::ML;

use Moo;
with 'Search::Elasticsearch::Plugin::XPack::5_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('xpack.ml');

1;

# ABSTRACT: Plugin providing ML API for Search::Elasticsearch 5.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack']
    );

    my $response = $es->xpack->ml->start_datafeed(...)

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with an C<ml>
namespace, to support the
L<Machine Learning APIs|https://www.elastic.co/guide/en/x-pack/6.0/xpack-ml.html>.
In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes    => \@nodes,
        plugins  => ['XPack']
    );

    my $response = $es->xpack->ml->start_datafeed(...);

The full documentation for the ML feature is available here:
L<https://www.elastic.co/guide/en/x-pack/6.0/xpack-ml.html>

=head1 DATAFEED METHODS

=head2 C<put_datafeed()>

    $response = $es->xpack->ml->put_datafeed(
        datafeed_id => $id      # required
        body        => {...}    # required
    )

The C<put_datafeed()> method enables you to instantiate a datafeed.

See the L<put_datafeed docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-put-datafeed.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_datafeed()>

    $response = $es->xpack->ml->delete_datafeed(
        datafeed_id => $id      # required
    )

The C<delete_datafeed()> method enables you to delete a datafeed.

See the L<delete_datafeed docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-datafeed.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<force>,
    C<human>

=head2 C<start_datafeed()>

    $response = $es->xpack->ml->start_datafeed(
        datafeed_id => $id      # required
    )

The C<start_datafeed()> method enables you to start a datafeed.

See the L<start_datafeed docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-start-datafeed.html>
for more information.

Query string parameters:
    C<end>,
    C<error_trace>,
    C<human>,
    C<start>,
    C<timeout>

=head2 C<stop_datafeed()>

    $response = $es->xpack->ml->stop_datafeed(
        datafeed_id => $id      # required
    )

The C<stop_datafeed()> method enables you to stop a datafeed.

See the L<stop_datafeed docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-stop-datafeed.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<force>,
    C<human>,
    C<timeout>

=head2 C<get_datafeeds()>

    $response = $es->xpack->ml->get_datafeeds(
        datafeed_id => $id      # optional
    )

The C<get_datafeeds()> method enables you to retrieve configuration information for datafeeds.

See the L<get_datafeeds docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-datafeed.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_datafeed_stats()>

    $response = $es->xpack->ml->get_datafeed_stats(
        datafeed_id => $id      # optional
    )

The C<get_datafeed_stats()> method enables you to retrieve configuration information for datafeeds.

See the L<get_datafeed_stats docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-datafeed-stats.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<preview_datafeed()>

    $response = $es->xpack->ml->preview_datafeed(
        datafeed_id => $id      # required
    )

The C<preview_datafeed()> method enables you to preview a datafeed.

See the L<preview_datafeed docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-preview-datafeed.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<update_datafeed()>

    $response = $es->xpack->ml->update_datafeed(
        datafeed_id => $id      # required
        body        => {...}    # required
    )

The C<update_datafeed()> method enables you to update certain properties of a datafeed.

See the L<update_datafeed docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-update-datafeed.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head1 JOB METHODS

=head2 C<put_job()>

    $response = $es->xpack->ml->put_job(
        job_id => $id           # required
        body        => {...}    # required
    )

The C<put_job()> method enables you to instantiate a job.

See the L<put_job docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-put-job.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<delete_job()>

    $response = $es->xpack->ml->delete_job(
        job_id => $id           # required
    )

The C<delete_job()> method enables you to delete a job.

See the L<delete_job docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-job.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<force>,
    C<human>

=head2 C<open_job()>

    $response = $es->xpack->ml->open_job(
        job_id => $id           # required
    )

The C<open_job()> method enables you to open a closed job.

See the L<open_job docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-open-job.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<close_job()>

    $response = $es->xpack->ml->close_job(
        job_id => $id           # required
    )

The C<close_job()> method enables you to close an open job.

See the L<close_job docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-close-job.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<force>,
    C<human>,
    C<timeout>

=head2 C<get_jobs()>

    $response = $es->xpack->ml->get_jobs(
        job_id => $id           # optional
    )

The C<get_jobs()> method enables you to retrieve configuration information for jobs.

See the L<get_jobs docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-job.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_job_stats()>

    $response = $es->xpack->ml->get_jobs_stats(
        job_id => $id           # optional
    )

The C<get_jobs_stats()> method enables you to retrieve usage information for jobs.

See the L<get_job_statss docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-job-stats.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>


=head2 C<flush_job()>

    $response = $es->xpack->ml->flush_job(
        job_id => $id           # required
    )

The C<flush_job()> method forces any buffered data to be processed by the job.

See the L<flush_job docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-flush-job.html>
for more information.

Query string parameters:
    C<advance_time>,
    C<calc_interm>,
    C<end>,
    C<error_trace>,
    C<human>,
    C<skip_time>,
    C<start>

=head2 C<post_data()>

    $response = $es->xpack->ml->post_data(
        job_id => $id           # required
        body   => [data]        # required
    )

The C<post_data()> method enables you to send data to an anomaly detection job for analysis.

See the L<post_data docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-post-data.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<reset_end>,
    C<reset_start>

=head2 C<update_job()>

    $response = $es->xpack->ml->update_job(
        job_id => $id           # required
        body        => {...}    # required
    )

The C<update_job()> method enables you to update certain properties of a job.

See the L<update_job docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-update-job.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>


=head1 MODEL SNAPSHOT METHODS

=head2 C<delete_model_snapshot()>

    $response = $es->xpack->ml->delete_model_snapshot(
        snapshot_id => $id      # required
    )

The C<delete_model_snapshot()> method enables you to delete an existing model snapshot.

See the L<delete_model_snapshot docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-delete-snapshot.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head2 C<get_model_snapshots()>

    $response = $es->xpack->ml->get_model_snapshots(
        job_id      => $job_id,         # required
        snapshot_id => $snapshot_id     # optional
    )

The C<get_model_snapshots()> method enables you to retrieve information about model snapshots.

See the L<get_model_snapshots docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-snapshot.html>
for more information.

Query string parameters:
    C<desc>,
    C<end>,
    C<error_trace>,
    C<from>,
    C<human>,
    C<size>,
    C<sort>,
    C<start>

=head2 C<revert_model_snapshot()>

    $response = $es->xpack->ml->revert_model_snapshot(
        job_id      => $job_id,         # required
        snapshot_id => $snapshot_id     # required
    )

The C<revert_model_snapshots()> method enables you to revert to a specific snapshot.

See the L<revert_model_snapshot docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-revert-snapshot.html>
for more information.

Query string parameters:
    C<delete_intervening_results>,
    C<error_trace>,
    C<human>

=head2 C<update_model_snapshot()>

    $response = $es->xpack->ml->update_model_snapshot(
        job_id      => $job_id,         # required
        snapshot_id => $snapshot_id     # required
    )

The C<update_model_snapshots()> method enables you to update certain properties of a snapshot.

See the L<update_model_snapshot docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-update-snapshot.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>

=head1 RESULT METHODS

=head2 C<get_buckets()>

    $response = $es->xpack->ml->get_buckets(
        job_id      => $job_id,         # required
        timestamp   => $timestamp       # optional
    )

The C<get_buckets()> method enables you to retrieve job results for one or more buckets.

See the L<get_buckets docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-bucket.html>
for more information.

Query string parameters:
    C<anomaly_score>,
    C<desc>,
    C<end>,
    C<error_trace>,
    C<exclude_interim>,
    C<expand>,
    C<from>,
    C<human>,
    C<size>,
    C<sort>,
    C<start>

=head2 C<get_categories()>

    $response = $es->xpack->ml->get_categories(
        job_id      => $job_id,         # required
        category_id => $category_id     # optional
    )

The C<get_categories()> method enables you to retrieve job results for one or more categories.

See the L<get_categories docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-category.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<from>,
    C<human>,
    C<size>


=head2 C<get_influencers()>

    $response = $es->xpack->ml->get_influencers(
        job_id      => $job_id,         # required
    )

The C<get_influencers()> method enables you to retrieve job results for one or more influencers.

See the L<get_influencers docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-influencer.html>
for more information.

Query string parameters:
    C<desc>,
    C<end>,
    C<error_trace>,
    C<exclude_interim>,
    C<expand>,
    C<from>,
    C<human>,
    C<influencer_score>,
    C<size>,
    C<sort>,
    C<start>

=head2 C<get_records()>

    $response = $es->xpack->ml->get_records(
        job_id      => $job_id,         # required
    )

The C<get_records()> method enables you to retrieve anomaly records for a job.

See the L<get_records docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ml-get-record.html>
for more information.

Query string parameters:
    C<desc>,
    C<end>,
    C<error_trace>,
    C<exclude_interim>,
    C<expand>,
    C<from>,
    C<human>,
    C<record_score>,
    C<size>,
    C<sort>,
    C<start>
