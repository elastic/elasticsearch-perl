# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Cxn::Factory;

use Moo;
use Search::Elasticsearch::Util qw(parse_params load_plugin);
use namespace::clean;

has 'cxn_class'          => ( is => 'ro', required => 1 );
has '_factory'           => ( is => 'ro', required => 1 );
has 'default_host'       => ( is => 'ro', default  => 'http://localhost:9200' );
has 'max_content_length' => ( is => 'rw', default  => 104_857_600 );

#===================================
sub BUILDARGS {
#===================================
    my ( $class, $params ) = parse_params(@_);
    my %args = (%$params);
    delete $args{nodes};

    my $cxn_class
        = load_plugin( 'Search::Elasticsearch::Cxn', delete $args{cxn} );
    $params->{_factory} = sub {
        my ( $self, $node ) = @_;
        $cxn_class->new(
            %args,
            node               => $node,
            max_content_length => $self->max_content_length
        );
    };
    $params->{cxn_args}  = \%args;
    $params->{cxn_class} = $cxn_class;
    return $params;
}

#===================================
sub new_cxn { shift->_factory->(@_) }
#===================================

1;

__END__

# ABSTRACT: Used by CxnPools to create new Cxn instances.

=head1 DESCRIPTION

This class is used by the L<Search::Elasticsearch::Role::CxnPool> implementations
to create new L<Search::Elasticsearch::Role::Cxn>-based instances. It holds on
to all the configuration options passed to L<Elasticsearch/new()> so
that new Cxns can use them.

It contains no user serviceable parts.
