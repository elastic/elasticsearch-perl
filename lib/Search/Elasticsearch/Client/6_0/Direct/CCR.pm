package Search::Elasticsearch::Client::6_0::Direct::CCR;

use Moo;
with 'Search::Elasticsearch::Client::6_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use Search::Elasticsearch::Util qw(parse_params);
use namespace::clean;
__PACKAGE__->_install_api('ccr');

1;

__END__

# ABSTRACT: Plugin providing cross-cluster replication APIs for Search::Elasticsearch 6.x

=head2 DESCRIPTION

This module provides methods to use the cross-cluster replication feature.

The full documentation for CCR is available here:
L<https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-apis.html>

=head1 FOLLOW METHODS

=head2 C<follow()>

    $response = $es->ccr->follow(
        index   => $index,  # required
        body    => {...}    # required
    )

The C<follow()> method creates a new follower index that is configured to follow the referenced leader index.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>,
    C<wait_for_active_shards>

See the L<CCR follow docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-put-follow.html>
for more information.


=head2 C<pause_follow()>

    $response = $es->ccr->pause_follow(
        index   => $index,  # required
    )

The C<pause_follow()> method pauses following of an index.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR pause follow docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-pause-follow.html>
for more information.


=head2 C<resume_follow()>

    $response = $es->ccr->resume_follow(
        index   => $index,  # required
    )

The C<resume_follow()> method resumes following of an index.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR resume follow docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-resume-follow.html>
for more information.


=head2 C<unfollow()>

    $response = $es->ccr->unfollow(
        index   => $index,  # required
    )

The C<unfollow()> method converts a follower index into a normal index.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR unfollow docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-unfollow.html>
for more information.


=head2 C<forget_follower()>

    $response = $es->ccr->forget_follower(
        index   => $index,  # required
    )

The C<forget_follower()> method removes the follower retention leases from the leader.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR forget_follower docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-post-forget-follower.html>
for more information.

=head1 STATS METHODS

=head2 C<stats()>

    $response = $es->ccr->stats()

The C<stats()> method returns all stats related to cross-cluster replication.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR stats docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-stats.html>
for more information.

=head2 C<follow_stats()>

    $response = $es->ccr->follow_stats(
        index   => $index | \@indices,  # optional
    )

The C<follow_stats()> method returns shard-level stats about follower indices.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR follow stats docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-follow-stats.html>
for more information.


=head2 C<follow_info()>

    $response = $es->ccr->follow_info(
        index   => $index | \@indices,  # optional
    )

The C<follow_info()> method returns the parameters and the status for each follower index.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR follow info docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-follow-info.html>
for more information.

=head1 AUTO-FOLLOW METHODS

=head2 C<put_auto_follow_pattern()>

    $response = $es->ccr->put_auto_follow_pattern(
        name    => $name    # required
    )

The C<put_auto_follow_pattern()> method creates a new named collection of auto-follow patterns against the remote cluster specified in the request body.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR put auto follow pattern docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-put-auto-follow-pattern.html>
for more information.


=head2 C<get_auto_follow_pattern()>

    $response = $es->ccr->get_auto_follow_pattern(
        name    => $name    # optional
    )

The C<get_auto_follow_pattern()> method retrieves a named collection of auto-follow patterns, or all patterns.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR get auto follow pattern docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-get-auto-follow-pattern.html>
for more information.

=head2 C<delete_auto_follow_pattern()>

    $response = $es->ccr->delete_auto_follow_pattern(
        name    => $name    # required
    )

The C<delete_auto_follow_pattern()> method deletes a named collection of auto-follow patterns.

Query string parameters:
    C<error_trace>,
    C<filter_path>,
    C<human>

See the L<CCR delete auto follow pattern docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/ccr-delete-auto-follow-pattern.html>
for more information.


