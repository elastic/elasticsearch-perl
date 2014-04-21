package Search::Elasticsearch::Serializer::JSON;

use strict;
use warnings;
use Module::Runtime qw(use_module);

#===================================
sub new {
#===================================
    my ( $class, $params ) = @_;
    my $module = _choose_json_module();
    $class = __PACKAGE__ . '::' . $module;
    use_module($class);
    $class->new($params);
}

#===================================
sub _choose_json_module {
#===================================
    return 'Cpanel' if $INC{'Cpanel/JSON/XS.pm'};
    return 'XS'     if $INC{'JSON/XS.pm'};

    my @err;

    return 'Cpanel' if eval { require Cpanel::JSON::XS; 1; };
    push @err, "Error loading Cpanel::JSON::XS: $@";

    return 'XS' if eval { require JSON::XS; 1; };
    push @err, "Error loading JSON::XS: $@";

    return 'PP' if eval { require JSON::PP; 1 };
    push @err, "Error loading JSON::PP: $@";

    die join( "\n", "Couldn't load a JSON module:", @err );

}

1;

# ABSTRACT: The default JSON Serializer

=head1 SYNOPSIS

    $e = Search::Elasticsearch(
        # serializer => 'JSON'
    );

=head1 DESCRIPTION

This default Serializer class chooses between:

=over

=item * L<Cpanel::JSON::XS>

=item * L<JSON::XS>

=item * L<JSON::PP>

=back

First it checks if either L<Cpanel::JSON::XS> or L<JSON::XS> is already
loaded and, if so, uses the appropriate backend.  Otherwise it tries
to load L<Cpanel::JSON::XS>, then L<JSON::XS> and finally L<JSON::PP>.

If you would prefer to specify a particular JSON backend, then you can
do so by using one of these modules:

=over

=item * L<Search::Elasticsearch::Serializer::JSON::Cpanel>

=item * L<Search::Elasticsearch::Serializer::JSON::XS>

=item * L<Search::Elasticsearch::Serializer::JSON::PP>

=back

See their documentation for details.

