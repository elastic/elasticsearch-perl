package Search::Elasticsearch::Plugin::XPack::5_0;

use Moo::Role;
use namespace::clean;

has 'graph'   => ( is => 'lazy', init_arg => undef );
has 'license' => ( is => 'lazy', init_arg => undef );
has 'security'  => ( is => 'lazy', init_arg => undef );
has 'watcher' => ( is => 'lazy', init_arg => undef );


sub _build_graph {
    shift->_build_namespace(
        '+Search::Elasticsearch::Plugin::XPack::5_0::Graph');
}

sub _build_license {
    shift->_build_namespace(
        '+Search::Elasticsearch::Plugin::XPack::5_0::License');
}

sub _build_security {
    shift->_build_namespace(
        '+Search::Elasticsearch::Plugin::XPack::5_0::Security');
}

sub _build_watcher {
    shift->_build_namespace(
        '+Search::Elasticsearch::Plugin::XPack::5_0::Watcher');
}

1;

# ABSTRACT: Plugin providing XPack APIs for Search::Elasticsearch v5.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['XPack']
    );

    $es->graph;
    $es->license;
    $es->security;
    $es->watcher;

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client to add support
for the X-Pack commercial plugins for Elasticsearch 5.x.

It extends the L<Search::Elasticsearch> client with a C<graph>, C<license>,
C<security>, and C<watcher> namespace, to support the APIs for the X-Pack plugins:
Graph, License, Shield, and Watcher.

In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['XPack']
    );

    my $response = $es->watcher->info();

For details about the supported methods in each namespace, see:

=over

=item *

L<graph()/Search::Elasticsearch::Plugin::XPack::5_0::Graph>

=item *

L<license()/Search::Elasticsearch::Plugin::XPack::5_0::License>

=item *

L<shield()/Search::Elasticsearch::Plugin::XPack::5_0::Security>

=item *

L<watcher()/Search::Elasticsearch::Plugin::XPack::5_0::Watcher>

=back

