package Search::Elasticsearch::Client::7_0::Direct::Graph;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('graph');

1;

__END__

# ABSTRACT: Plugin providing Graph API for Search::Elasticsearch 7.x

=head1 SYNOPSIS

    my $response = $es->graph->explore(...);

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client with a C<graph>
namespace, to support the API for the
L<Graph|https://www.elastic.co/guide/en/x-pack/current/xpack-graph.html> plugin for Elasticsearch.

=head1 METHODS

The full documentation for the Graph plugin is available here:
L<https://www.elastic.co/guide/en/graph/current/index.html>

=head2 C<explore()>

    $response = $es->graph->explore(
        index => $index | \@indices,        # optional
        type  => $type  | \@types,          # optional
        body  => {...}
    )

The C<explore()> method allows you to discover vertices and connections which relate
to your query.

See the L<explore docs|https://www.elastic.co/guide/en/elasticsearch/reference/current/graph-explore-api.html>
for more information.

Query string parameters:
    C<error_trace>,
    C<human>,
    C<routing>,
    C<timeout>
