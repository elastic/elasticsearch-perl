package Search::Elasticsearch::Client::5_0::Async;

our $VERSION='5.00';
use Search::Elasticsearch::Client::5_0 5.00 ();

1;

__END__

# ABSTRACT: Thin async client with full support for Elasticsearch 5.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::5_0::Async> package provides a client
compatible with Elasticsearch 5.x.  It should be used in conjunction
with L<Search::Elasticsearch::Async> as follows:

    $e = Search::Elasticsearch::Async->new(
        client => "5_0::Direct"
    );

See L<Search::Elasticsearch::Client::5_0::Direct> for documentation
about how to use the client itself.

=head1 PREVIOUS VERSIONS OF ELASTICSEARCH

This version of the client supports the Elasticsearch 5.0 branch,
which is not backwards compatible with earlier branches.

If you need to talk to a version of Elasticsearch before 5.0.0, please
install one of the following packages:

=over

=item *

L<Search::Elasticsearch::Client::2_0::Async>

=item *

L<Search::Elasticsearch::Client::1_0::Async>

=item *

L<Search::Elasticsearch::Client::0_90::Async>

=back
