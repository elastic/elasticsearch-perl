package Elasticsearch::Util::API::Path;

use strict;
use warnings;
use Any::URI::Escape qw(uri_escape);

use Sub::Exporter -setup => { exports => ['path_init'] };

our %Handler = (
    '{field}'           => sub { multi_req( 'field', @_ ) },
    '{id}'              => sub { one_req( 'id',      @_ ) },
    '{id|blank}'        => sub { one_opt( 'id',      @_ ) },
    '{index}'           => sub { one_req( 'index',   @_ ) },
    '{index|blank}'     => sub { one_opt( 'index',   @_ ) },
    '{index-when-type}' => sub { index_plus( 'type', @_ ) },
    '{indices}'         => sub { multi_opt( 'index', @_ ) },
    '{indices|all}'      => sub { multi_opt( 'index',   @_, '_all' ) },
    '{indices|all-type}' => sub { indices_plus( 'type', @_ ) },
    '{req_indices}'      => sub { multi_req( 'index',   @_ ) },
    '{req_types}'        => sub { multi_req( 'type',    @_ ) },
    '{metrics}'          => sub { multi_opt( 'metric',  @_, '_all' ) },
    '{names}'         => sub { multi_opt( 'name',          @_, '*' ) },
    '{names|blank}'   => sub { multi_opt( 'name',          @_ ) },
    '{name}'          => sub { one_req( 'name',            @_ ) },
    '{name|blank}'    => sub { one_opt( 'name',            @_ ) },
    '{nodes}'         => sub { multi_opt( 'node_id',       @_, '_all' ) },
    '{nodes|blank}'   => sub { multi_opt( 'node_id',       @_ ) },
    '{scroll_ids}'    => sub { multi_req( 'scroll_id',     @_ ) },
    '{type}'          => sub { one_req( 'type',            @_ ) },
    '{type|all}'   => sub { one_opt( 'type',   @_, '_all' ) },
    '{type|blank}' => sub { one_opt( 'type',   @_ ) },
    '{types}'      => sub { multi_opt( 'type', @_ ) },

    # for 0.90
    '{metric|blank}' => \&metric_or_blank,
);

#===================================
sub path_init {
#===================================
    my $template = shift;
    my @handlers = map {
        my $part = $_;
        $Handler{$part}
            || sub {$part}
    } split '/', $template;

    return sub {
        my $params = shift;
        return join '/', '', map { utf8::encode($_); uri_escape($_) }
            grep { defined and length } map { $_->($params) } @handlers;
    };
}

#===================================
sub index_plus {
#===================================
    my ( $plus, $params ) = @_;
    return $params->{$plus}
        ? one_req( 'index', $params )
        : one_opt( 'index', $params );
}

#===================================
sub indices_plus {
#===================================
    my ( $plus, $params ) = @_;
    return $params->{$plus}
        ? multi_opt( 'index', $params, '_all' )
        : multi_opt( 'index', $params );
}

#===================================
sub one_opt {
#===================================
    my ( $name, $params, $default ) = @_;
    my $val = delete $params->{$name};
    return $default unless defined $val and length $val;
    die "Param ($name) must contain a single value\n"
        if ref $val eq 'ARRAY';
    return $val;
}

#===================================
sub one_req {
#===================================
    my ( $name, $params ) = @_;
    my $val = delete $params->{$name};
    die "Missing required param ($name)\n"
        unless defined $val and length $val;
    die "Param ($name) must contain a single value\n"
        if ref $val eq 'ARRAY';
    return $val;
}

#===================================
sub multi_opt {
#===================================
    my ( $name, $params, $default ) = @_;
    my $val = delete $params->{$name};
    return $default unless defined $val and length $val;
    return ref $val eq 'ARRAY' ? join ',', @$val : $val;
}

#===================================
sub multi_req {
#===================================
    my ( $name, $params, $default ) = @_;
    my $val = delete $params->{$name};
    $val = join ',', @$val if ref $val eq 'ARRAY';
    die "Param ($name) must contain at least one value\n"
        unless defined $val and length $val;
    return $val;
}

#===================================
sub metric_or_blank {
#===================================
    my ( $params, $default ) = @_;
    my $metric = delete $params->{metric} or return;
    die "Param (metric) must contain a single value\n"
        if ref $metric eq 'ARRAY';
    delete $params->{indices};
    return ( 'indices', $metric );
}

1;

__END__

# ABSTRACT: A utility class for converting path templates into real paths

=head1 DESCRIPTION

This module converts path templates in L<Elasticsearch::Role::API> such as
C</{index}/{type}/{id}> into real paths such as C</my_index/my_type/123>.

=head1 EXPORTS

=head2 C<path_init()>

    use Elasticsearch::Util::API::Path qw(path_init);

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

