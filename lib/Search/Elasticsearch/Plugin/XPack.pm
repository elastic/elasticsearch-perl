package Search::Elasticsearch::Plugin::XPack;

use Moo;

use Search::Elasticsearch 2.02 ();

our $VERSION = '2.02';

#===================================
sub _init_plugin {
#===================================
    my ( $class, $params ) = @_;

    my $api_version = $params->{client}->api_version;

    Moo::Role->apply_roles_to_object( $params->{client},
        "Search::Elasticsearch::Plugin::XPack::${api_version}" );
}

1

__END__

# ABSTRACT: Plugin providing XPack APIs for Search::Elasticsearch

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        plugins => ['XPack']
    );

=head2 DESCRIPTION

This class extends the L<Search::Elasticsearch> client to add support
for the X-Pack commercial plugins.

This plugin will detect which version of the Elasticsearch API you are using
and load the corresponding XPack API.

For more details, see:

=over

=item *

L<Search::Elasticsearch::Plugin::XPack::2_0>

=item *

L<Search::Elasticsearch::Plugin::XPack::1_0>

=back

