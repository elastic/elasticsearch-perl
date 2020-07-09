package Search::Elasticsearch::Client::6_0;

our $VERSION='7.30_1';
use Search::Elasticsearch 7.00 ();

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch 6.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::6_0> package provides a client
compatible with Elasticsearch 6.x.  It should be used in conjunction
with L<Search::Elasticsearch> as follows:

    $e = Search::Elasticsearch->new(
        client => "6_0::Direct"
    );

See L<Search::Elasticsearch::Client::6_0::Direct> for documentation
about how to use the client itself.

=head1 PREVIOUS VERSIONS OF ELASTICSEARCH

This version of the client supports the Elasticsearch 6.0 branch,
which is not backwards compatible with earlier branches.

If you need to talk to a version of Elasticsearch before 6.0.0, please
install one of the following packages:

=over

=item *

L<Search::Elasticsearch::Client::5_0>

=item *

L<Search::Elasticsearch::Client::2_0>

=item *

L<Search::Elasticsearch::Client::1_0>

=item *

L<Search::Elasticsearch::Client::0_90>

=back
