package Search::Elasticsearch::Client::2_0;

our $VERSION='6.80';
use Search::Elasticsearch 6.00 ();

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch 2.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::2_0> package provides a client
compatible with Elasticsearch 2.x.  It should be used in conjunction
with L<Search::Elasticsearch> as follows:

    $e = Search::Elasticsearch->new(
        client => "2_0::Direct"
    );

See L<Search::Elasticsearch::Client::2_0::Direct> for documentation
about how to use the client itself.
