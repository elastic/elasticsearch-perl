package Search::Elasticsearch::Client::0_90::Async;

our $VERSION='5.00';
use Search::Elasticsearch::Client::0_90 5.00 ();

1;

__END__

# ABSTRACT: Thin async client with full support for Elasticsearch 2.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::0_90::Async> package provides a client
compatible with Elasticsearch 0.90.x.  It should be used in conjunction
with L<Search::Elasticsearch::Async> as follows:

    $e = Search::Elasticsearch::Async->new(
        client => "0_90::Direct"
    );

See C<Search::Elasticsearch::Client::0_90::Direct> for documentation
about how to use the client itself.

