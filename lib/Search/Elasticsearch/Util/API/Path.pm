package Search::Elasticsearch::Util::API::Path;

use strict;
use warnings;
use Any::URI::Escape qw(uri_escape);
use Search::Elasticsearch::Util qw(throw);
use Sub::Exporter -setup => { exports => ['path_handler'] };

#===================================
sub path_handler {
#===================================
    my ( $defn, $params ) = @_;
    my $paths = $defn->{paths};
    my $parts = $defn->{parts};

    my %args;
    keys %$parts;
    no warnings 'uninitialized';
    while ( my ( $key, $req ) = each %$parts ) {
        my $val = delete $params->{$key};
        if ( ref $val eq 'ARRAY' ) {
            die "Param ($key) must contain a single value\n"
                if @$val > 1 and not $req->{multi};
            $val = join ",", @$val;
        }
        if ( !length $val ) {
            die "Missing required param ($key)\n"
                if $req->{required};
            next;
        }
        utf8::encode($val);
        $args{$key} = uri_escape($val);
    }
PATH: for my $path (@$paths) {
        my @keys = keys %{ $path->[0] };
        next PATH unless @keys == keys %args;
        for (@keys) {
            next PATH unless exists $args{$_};
        }
        my ( $pos, @parts ) = @$path;
        for ( keys %$pos ) {
            $parts[ $pos->{$_} ] = $args{$_};
        }
        return join "/", '', @parts;
    }

    die "Param (index) required when (type) specified\n"
        if $defn->{index_when_type} && $args{type} && !$args{index};

    throw(
        'Internal',
        "Couldn't determine path",
        { params => $params, defn => $defn }
    );
}

1;

__END__

# ABSTRACT: A utility class for converting path templates into real paths

=head1 DESCRIPTION

This module converts path templates in L<Search::Elasticsearch::Role::API> such as
C</{index}/{type}/{id}> into real paths such as C</my_index/my_type/123>.

=head1 EXPORTS

=head2 C<path_init()>

    use Search::Elasticsearch::Util::API::Path qw(path_init);

    $handler = path_init($template);
    $path    = $handler->(\%params);

The C<path_init()> sub accepts a path template and returns an anonymous sub
which converts C<\%params> into a real path, removing the keys that it
has used from C<%params>, eg:

    $handler = path_init('/{indices}/_search');
    $params  = { index => ['foo','bar'], size => 10 };
    $path    = $handler->($params);

Would result in:

    $path:      '/foo,bar/_search';
    $params:    { size => 10 };

