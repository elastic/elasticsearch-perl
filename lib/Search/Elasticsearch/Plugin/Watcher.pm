package Search::Elasticsearch::Plugin::Watcher;

use Moo;
with 'Search::Elasticsearch::Plugin::Watcher::API';
with 'Search::Elasticsearch::Role::Client::Direct';
__PACKAGE__->_install_api('watcher');

use Search::Elasticsearch 2.00 ();

our $VERSION = '2.03';

#===================================
sub _init_plugin {
#===================================
    my ( $class, $params ) = @_;

    Moo::Role->apply_roles_to_object( $params->{client},
        qw(Search::Elasticsearch::Plugin::Watcher::Namespace) );
}

package Search::Elasticsearch::Plugin::Watcher::Namespace;

use Moo::Role;

has 'watcher' => ( is => 'lazy', init_arg => undef );

sub _build_watcher {
    shift->_build_namespace('+Search::Elasticsearch::Plugin::Watcher');
}

1;

__END__

# ABSTRACT: DEPRECATED Plugin providing Watcher API for Search::Elasticsearch

=head1 DESCRIPTION

See L<Search::Elasticsearch::Plugin::XPack> instead.
