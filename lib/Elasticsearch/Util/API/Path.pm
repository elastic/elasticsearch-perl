package Elasticsearch::Util::API::Path;

use strict;
use warnings;
use URI::Escape qw(uri_escape_utf8);

use Sub::Exporter -setup => { exports => ['path_handler'] };

our %Handler = (
    '{aliases}'          => sub { multi_opt( 'alias',  shift(), '*' ) },
    '{alias}'            => sub { one_req( 'alias',    shift() ) },
    '{id}'               => sub { one_req( 'id',       shift() ) },
    '{id|blank}'         => sub { one_opt( 'id',       shift() ) },
    '{index}'            => sub { one_req( 'index',    shift() ) },
    '{index|blank}'      => sub { one_opt( 'index',    shift() ) },
    '{indices}'          => sub { multi_opt( 'index',  shift() ) },
    '{indices|all}'      => sub { multi_opt( 'index',  shift(), '_all' ) },
    '{req_indices}'      => sub { multi_req( 'index',  shift() ) },
    '{type}'             => sub { one_req( 'type',     shift() ) },
    '{type|all}'         => sub { one_opt( 'type',     shift(), '_all' ) },
    '{type|blank}'       => sub { one_opt( 'type',     shift() ) },
    '{types}'            => sub { multi_opt( 'type',   shift() ) },
    '{req_types}'        => sub { multi_req( 'type',   shift() ) },
    '{nodes}'            => sub { multi_opt( 'node',   shift() ) },
    '{template}'         => sub { one_req( 'template', shift() ) },
    '{warmer}'           => sub { one_req( 'warmer',   shift() ) },
    '{warmer|blank}'     => sub { one_opt( 'warmer',   shift() ) },
    '{indices|all-type}' => sub { index_plus( 'type',  shift() ) },
    '{indices|all-warmer}' => sub { index_plus( 'warmer', shift() ) },
);

#===================================
sub path_handler {
#===================================
    my ( $template, $params ) = @_;
    my @parts;
    for ( split '/', $template ) {
        if ( my $handler = $Handler{$_} ) {
            my $val = $handler->($params);
            next unless defined $val and length $val;
            push @parts, uri_escape_utf8($val);
        }
        else {
            push @parts, $_;
        }
    }
    return join '/', '', @parts;
}

#===================================
sub index_plus {
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
