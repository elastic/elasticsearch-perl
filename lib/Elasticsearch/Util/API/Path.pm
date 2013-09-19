package Elasticsearch::Util::API::Path;

use strict;
use warnings;
use Any::URI::Escape qw(uri_escape);

use Sub::Exporter -setup => { exports => ['path_init'] };

our %Handler = (
    '{aliases}'            => sub { multi_opt( 'alias',     @_, '*' ) },
    '{alias}'              => sub { one_req( 'alias',       @_ ) },
    '{id}'                 => sub { one_req( 'id',          @_ ) },
    '{id|blank}'           => sub { one_opt( 'id',          @_ ) },
    '{index}'              => sub { one_req( 'index',       @_ ) },
    '{index|blank}'        => sub { one_opt( 'index',       @_ ) },
    '{index-when-type}'    => sub { index_plus( 'type',     @_ ) },
    '{indices}'            => sub { multi_opt( 'index',     @_ ) },
    '{indices|all}'        => sub { multi_opt( 'index',     @_, '_all' ) },
    '{req_indices}'        => sub { multi_req( 'index',     @_ ) },
    '{names}'              => sub { multi_opt( 'name',      @_, '*' ) },
    '{name}'               => sub { one_req( 'name',        @_ ) },
    '{type}'               => sub { one_req( 'type',        @_ ) },
    '{type|all}'           => sub { one_opt( 'type',        @_, '_all' ) },
    '{type|blank}'         => sub { one_opt( 'type',        @_ ) },
    '{types}'              => sub { multi_opt( 'type',      @_ ) },
    '{req_types}'          => sub { multi_req( 'type',      @_ ) },
    '{nodes}'              => sub { multi_opt( 'node',      @_ ) },
    '{template}'           => sub { one_req( 'template',    @_ ) },
    '{warmer}'             => sub { one_req( 'warmer',      @_ ) },
    '{warmers}'            => sub { multi_opt( 'warmer',    @_ ) },
    '{indices|all-type}'   => sub { indices_plus( 'type',   @_ ) },
    '{indices|all-warmer}' => sub { indices_plus( 'warmer', @_ ) },
);

#===================================
sub path_init {
#===================================
    my $template = shift;
    my @handlers = map {
        my $part = $_;
        $Handler{$part}
            || sub {$part}
    } split '/', $template || 'FOO';

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
1;
