package Search::Elasticsearch::Client::7_0::Direct::XPack;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';

use namespace::clean;
sub _namespace {__PACKAGE__}

has 'graph'      => ( is => 'lazy', init_arg => undef );
has 'license'    => ( is => 'lazy', init_arg => undef );
has 'migration'  => ( is => 'lazy', init_arg => undef );
has 'ml'         => ( is => 'lazy', init_arg => undef );
has 'monitoring' => ( is => 'lazy', init_arg => undef );
has 'rollup'     => ( is => 'lazy', init_arg => undef );
has 'security'   => ( is => 'lazy', init_arg => undef );
has 'sql'        => ( is => 'lazy', init_arg => undef );
has 'ssl'        => ( is => 'lazy', init_arg => undef );
has 'watcher'    => ( is => 'lazy', init_arg => undef );

sub _build_graph      { shift->_build_namespace('Graph') }
sub _build_license    { shift->_build_namespace('License') }
sub _build_migration  { shift->_build_namespace('Migration') }
sub _build_ml         { shift->_build_namespace('ML') }
sub _build_monitoring { shift->_build_namespace('Monitoring') }
sub _build_rollup     { shift->_build_namespace('Rollup') }
sub _build_security   { shift->_build_namespace('Security') }
sub _build_sql        { shift->_build_namespace('SQL') }
sub _build_ssl        { shift->_build_namespace('SSL') }
sub _build_watcher    { shift->_build_namespace('Watcher') }

__PACKAGE__->_install_api('xpack');

1;

__END__

# ABSTRACT: Plugin providing XPack APIs for Search::Elasticsearch v7.x

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes
    );

    $es->xpack->graph;
    $es->xpack->license;
    $es->xpack->security;
    $es->xpack->watcher;
    $es->xpack->rollup;
    $es->xpack->sql;
    $es->xpack->ml;

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client to add support
for the X-Pack commercial plugins for Elasticsearch 7.x.

It extends the L<Search::Elasticsearch> client with a C<graph>, C<license>, C<migration>, C<ml>,
C<security>, and C<watcher> namespace, to support the APIs for the X-Pack plugins:
Graph, License, Shield, and Watcher.

In other words, it can be used as follows:

    use Search::Elasticsearch();
    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes
    );

    my $response = $es->xpack->watcher->start();

For details about the supported methods in each namespace, see:

=over

=item *

L<graph()/Search::Elasticsearch::Client::7_0::XPack::Graph>

=item *

L<license()/Search::Elasticsearch::Client::7_0::XPack::License>

=item *

L<shield()/Search::Elasticsearch::Client::7_0::XPack::Migration>

=item *

L<shield()/Search::Elasticsearch::Client::7_0::XPack::ML>

=item *

L<shield()/Search::Elasticsearch::Client::7_0::XPack::Rollup>

=item *

L<shield()/Search::Elasticsearch::Client::7_0::XPack::Security>

=item *

L<shield()/Search::Elasticsearch::Client::7_0::XPack::SQL>

=item *

L<watcher()/Search::Elasticsearch::Client::7_0::XPack::Watcher>

=back

