package Search::Elasticsearch::Client::0_90;

our $VERSION='6.00';
use Search::Elasticsearch 6.00 ();

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch 0_90.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::0_90> package provides a client
compatible with Elasticsearch 0.90.x.  It should be used in conjunction
with L<Search::Elasticsearch> as follows:

    $e = Search::Elasticsearch->new(
        client => "0_90::Direct"
    );

See L<Search::Elasticsearch::Client::0_90::Direct> for documentation
about how to use the client itself.
