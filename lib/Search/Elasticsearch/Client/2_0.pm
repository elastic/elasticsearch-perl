package Search::Elasticsearch::Client::1_0;

our $VERSION='5.00';
use Search::Elasticsearch 5.00 ();

1;

__END__

# ABSTRACT: Thin client with full support for Elasticsearch 1.x APIs

=head1 DESCRIPTION

The L<Search::Elasticsearch::Client::1_0> package provides a client
compatible with Elasticsearch 1.x.  It should be used in conjunction
with L<Search::Elasticsearch> as follows:

    $e = Search::Elasticsearch->new(
        client => "1_0::Direct"
    );

See C<Search::Elasticsearch::Client::1_0::Direct> for documentation
about how to use the client itself.
