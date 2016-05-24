package Search::Elasticsearch::Plugin::XPack::1_0;

use Moo::Role;
use namespace::clean;

has 'watcher' => ( is => 'lazy', init_arg => undef );


sub _build_watcher {
    shift->_build_namespace(
        '+Search::Elasticsearch::Plugin::XPack::1_0::Watcher');
}


1;

# ABSTRACT: Plugin providing XPack APIs for Search::Elasticsearch v1.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['XPack']
    );

    $es->watcher;

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client to add support
for the X-Pack commercial plugins for Elasticsearch 1.x.

It extends the L<Search::Elasticsearch> client with a C<watcher> namespace,
to support the APIs for the Watcher plugin.

In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['XPack']
    );

    my $response = $es->watcher->info();

For details about the supported methods in the C<watcher> namespace, see,
L<watcher()/Search::Elasticsearch::Plugin::XPack::1_0::Watcher>.

