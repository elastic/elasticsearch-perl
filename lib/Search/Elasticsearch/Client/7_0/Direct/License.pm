package Search::Elasticsearch::Client::7_0::Direct::License;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('license');

1;

__END__

# ABSTRACT: Plugin providing License API for Search::Elasticsearch 7.x

=head1 SYNOPSIS

    my $response = $es->license->get();

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<license>
namespace, to support the API for the License plugin for Elasticsearch.

=head1 METHODS

The full documentation for the License plugin is available here:
L<https://www.elastic.co/guide/en/x-pack/current/license-management.html>

=head2 C<get()>

    $response = $es->license->get()

The C<get()> method returns the currently installed license.

See the L<license.get docs|https://www.elastic.co/guide/en/x-pack/current/listing-licenses.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<local>

=head2 C<post()>

    $response = $es->license->post(
        body     => {...}          # required
    );

The C<post()> method adds or updates the license for the cluster. The C<body>
can be passed as JSON or as a string.

See the L<license.put docs|https://www.elastic.co/guide/en/x-pack/current/installing-license.html>
for more information.

Query string parameters:
    C<acknowledge>,
    C<error_trace>,
    C<human>

=head2 C<get_basic_status()>

    $response = $es->license->get_basic_status()

This API enables you to check the status of your basic license.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<get-basic-status docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/get-basic-status.html> for more.

=head2 C<post_start_basic()>

    $response = $es->license->post_start_basic()

This API enables you to  initiate an indefinite basic license, which gives access to all the basic features.

Query string parameters:
    C<acknowledge>,
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<post-start-basic docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/start-basic.html> for more.


=head2 C<get_trial_status()>

    $response = $es->license->get_trial_status()

This API enables you to check the status of your trial license.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<get-trial-status docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/get-trial-status.html> for more.

=head2 C<post_start_trial()>

    $response = $es->license->post_start_trial()

This API enables you to upgrade from a basic license to a 30-day trial license, which gives
access to the platinum features.

Query string parameters:
    C<acknowledge>,
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<post-start-trial docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/start-trial.html> for more.


