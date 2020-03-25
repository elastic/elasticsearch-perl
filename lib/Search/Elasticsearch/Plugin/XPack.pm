package Search::Elasticsearch::Plugin::XPack;

use Moo;

our $VERSION = '6.80';
use Search::Elasticsearch 6.00 ();

#===================================
sub _init_plugin {
#===================================
    # NOOP
}

1;

# ABSTRACT: NOOP for backward compatibility wih XPack as plugin for Search::Elasticsearch

=head1 SYNOPSIS

    use Search::Elasticsearch();

    my $es = Search::Elasticsearch->new(
        nodes   => \@nodes,
        #plugins => ['XPack']  <-- NO NEED ANYMORE!
    );

=head2 DESCRIPTION

This is a NOOP module that is present only for backward compatibility.

Starting from elasticsearch-perl 6.8 we moved the XPack endpoints into Direct client.

You don't need anymore to specify XPack as plugin.