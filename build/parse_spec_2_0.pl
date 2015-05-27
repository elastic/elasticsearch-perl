#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use v5.12;
use Data::Dump qw(pp);
use Path::Class;
use Perl::Tidy;
use JSON::XS;

my @files = map { file($_) } glob '../elasticsearch/rest-api-spec/api/*.json';

my ( %API, %seen, %seen_combo, %Forbidden );

forbid(
    'GET' => qw(
        /_nodes/hotthreads
        /_nodes/{node_id}/hotthreads
        /_nodes/{metric}
        /_all/{type}/_mget
        /_all/{type}/_mpercolate
        /_all/{type}/_mtermvectors
        )
);

forbid( 'HEAD' => () );

forbid(
    'PUT' => qw(
        /{index}/{type}/_mapping
        )
);

forbid(
    'POST' => qw(
        /_all/{type}/_bulk
        /_all/{type}/_mget
        /_all/{type}/_mpercolate
        /_all/{type}/_mtermvectors
        )
);

forbid(
    'DELETE' => qw(
        /{index}/{type}
        /{index}/{type}/_mapping
        )
);

forbid(
    'QS' => qw(
        operation_threading
        field_data
        )
);

for my $file (@files) {
    say $file;
    my $data = decode_json( $file->slurp );
    my ( $name, $defn ) = %$data;
    die "File $file doesn't match name $name"
        unless $file =~ m{/$name.json};

    eval { $API{$name} = process( $name, $defn ) }
        || die "$name: $@";

}

# require index when type
for ( 'bulk', 'mget', 'mpercolate', 'mtermvectors' ) {
    $API{$_}{index_when_type} = 1;
}

update_module( shift(@ARGV) || 'lib/Search/Elasticsearch/Role/API/2_0.pm' );

#===================================
sub process {
#===================================
    my ( $name, $defn ) = @_;
    my %spec;

    # body
    if ( my $body = $defn->{body} ) {
        $spec{body}
            = $body->{required}
            ? { required => 1 }
            : {};
        if ( $body->{serialize} && $body->{serialize} eq 'bulk' ) {
            $spec{serialize} = 'bulk';
        }
    }

    # method
    my $method = $spec{method} = $defn->{methods}[0];
    delete $spec{method} if $method eq 'GET';

    # paths
    my $url = $defn->{url};
    $spec{paths} = process_paths( $name, $method, $url );

    # parts
    my $parts = $spec{parts} = process_parts( $url->{parts} );

    # default qs params
    unless ( $method eq 'HEAD' or ( $spec{paths}[0][1] || '' ) eq '_cat' ) {
        $url->{params}{filter_path} = 1;
    }

    # qs
    $spec{qs} = [
        sort grep { !$Forbidden{QS}{$_} }
        grep      { !$parts->{$_} } keys %{ $url->{params} }
    ];

    # doc
    $spec{doc} = $defn->{documentation} =~ m{/([^/]+)\.html$} ? $1 : '';

    return \%spec;
}

#===================================
sub process_paths {
#===================================
    my ( $name, $method, $url ) = @_;

    my @path_defns = map { process_path( $method, $_ ) } @{ $url->{paths} };

    my %sigs;
    for (@path_defns) {
        $_->{name} = $name;

        # check for duplicate params
        my $sig = $_->{sig};
        if ( my $exists = $sigs{$sig} ) {
            next if length( $exists->{path} ) <= length $_->{path};
        }
        $sigs{$sig} = $_;

        # check for duplicate wildcards
        warn "Duplicate paths: " . pp( [ $seen{ $_->{wildcard} }, $_ ] )
            if $seen{ $_->{wildcard} };

        $seen{ $_->{wildcard} } = $_;
    }

    # generate paths with _all
    my @paths;
    for my $path ( sort { $a->{max} <=> $b->{max} or $b->{sig} cmp $a->{sig} }
        values %sigs )
    {
        next if $path->{max} < 2;

        # find /{var1}/{var2} -> {var1} need _all
        my @parts = @{ $path->{parts} };
        while ( my $part = shift @parts ) {
            my $name = param_name($part) or next;
            next if $url->{parts}{$name}{required};
            next unless @parts && is_param( $parts[0] );
            my $new = replace_with_all( $method, $path->{path}, $part );
            next if !$new || $sigs{ $new->{sig} };
            push @paths, [ $new->{params}, @{ $new->{parts} } ];
        }
    }
    continue {
        push @paths, [ $path->{params}, @{ $path->{parts} } ];
    }
    return [ reverse @paths ];
}

#===================================
sub process_parts {
#===================================
    my $parts = shift;
    my %params;
    for my $key ( keys %$parts ) {
        my %defn;
        $defn{multi}    = 1 if $parts->{$key}{type} eq 'list';
        $defn{required} = 1 if $parts->{$key}{required};
        $params{$key}   = \%defn;
    }
    return \%params;
}

#===================================
sub replace_with_all {
#===================================
    my ( $method, $path, $param ) = @_;
    substr( $path, index( $path, $param ), length($param) ) = '_all';
    return process_path( $method, $path );
}

#===================================
sub is_param { substr( $_[0], 0, 1 ) eq '{' }
sub param_name { my $n = shift; $n =~ s/[{}]//g or return undef; $n; }
#===================================

#===================================
sub process_path {
#===================================
    my ( $method, $path ) = @_;
    return if $Forbidden{$method}{$path};
    my @parts = grep {$_} split /\//, $path;

    my $defn = {
        path  => $path,
        parts => \@parts,
    };

    my $count = 0;
    for my $i ( 0 .. $#parts ) {
        my $name = param_name( $parts[$i] ) or next;
        $count++;
        $defn->{params}{$name} = $i;
    }
    $defn->{max} = $count;
    $defn->{wildcard}
        = join "/",
        "$method ",
        map { is_param($_) ? '*' : $_ } @parts;

    $defn->{sig} = join "-", sort keys %{ $defn->{params} };

    return $defn;
}

#===================================
sub forbid {
#===================================
    my $method = shift;
    for (@_) {
        $Forbidden{$method}{$_} = 1;
    }
}

#===================================
sub update_module {
#===================================
    my $module   = shift;
    my $file     = file($module);
    my $contents = $file->slurp;
    my $out;
    if ( $contents =~ /^(.+\n#=== AUTOGEN - START ===\n\n)/s ) {
        $out = $1;
    }
    else {
        die "Couldn't find AUTOGEN - START marker";
    }

    my @keys = grep { !/\./ } sort keys %API;
    push @keys, grep {/\./} sort keys %API;

    for my $name (@keys) {
        $out .= "\n'$name' => " . pp( $API{$name} ) . ",\n";
    }

    if ( $contents =~ /(\n\n#=== AUTOGEN - END ===.+$)/s ) {
        $out .= $1;
    }
    else {
        die "Couldn't find AUTOGEN - END marker";
    }

    Perl::Tidy::perltidy(
        source      => \$out,
        destination => $module,
        argv        => '-q --indent-columns=4 --maximum-line-length=80 '
            . '-pbp -nst -sob -sot -vt=2 -nsob -sbcp=#='
    );

}
