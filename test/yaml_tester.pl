#!/usr/bin/env perl

use strict;
use warnings;
use YAML qw(LoadFile);
use Test::More;
use Test::Deep;
use Data::Dumper;
use File::Basename;

use lib qw(
    perl/lib
    perl-netcurl/lib
    perl-async/lib
    perl/t/lib
    perl-async/t/lib
    ../promises-perl/lib
);

my $client
    = $ENV{ES_ASYNC}
    ? 'es_async.pl'
    : 'es_sync.pl';

my $es = do $client or die $!;
my $wrapper = request_wrapper();

our %Test_Types = (
    is_true => sub {
        my ( $got, undef, $name ) = @_;
        ok( $got, $name );
    },
    is_false => sub {
        my ( $got, undef, $name ) = @_;
        no warnings 'uninitialized';
        ok( !$got, $name );
    },
    lt => sub {
        my ( $got, $expect, $name ) = @_;
        ok( $got < $expect, $name );
    },
    gt => sub {
        my ( $got, $expect, $name ) = @_;
        ok( $got > $expect, $name );
    },
    match  => \&cmp_deeply,
    length => \&test_length,
    catch  => \&test_error,
);

our %Errors = (
    missing   => 'Elasticsearch::Error::Missing',
    conflict  => 'Elasticsearch::Error::Conflict',
    forbidden => 'Elasticsearch::Error::ClusterBlocked',
    param     => 'Elasticsearch::Error::Param',
    request   => 'Elasticsearch::Error::Request',
);

my $test = shift @ARGV or die "No test specified";
if ( -d $test ) {
    test_dir($test);
}
else {
    test_files($test);
}

#===================================
sub test_dir {
#===================================
    my $dir = shift;
    plan tests   => 1;
    subtest $dir => sub {
        test_files( glob "$dir/*.yaml" );
    };
}

#===================================
sub test_files {
#===================================
    my @files = @_;

    reset_es();
    plan tests => 0 + @files;

    for my $file (@files) {
        my ($name) = ( $file =~ m{([\w.]+/[\w.]+\.yaml)} );
        my (@asts) = eval { LoadFile($file) } or do {
            fail "Error parsing test file ($file): $@";
            next;
        };

        subtest $name => sub {
            $es->logger->trace_comment("FILE: $file");

            my $setup;
            if ( $setup = $asts[0]{setup} ) {
                shift @asts;
                if ( check_skip( $name, $setup ) ) {
                    plan tests => 1;
                    return;
                }
            }

            plan tests => 0 + @asts;

            for my $ast (@asts) {

                my ( $title, $tests ) = key_val($ast);
                next if check_skip( $title, $tests );

                if ($setup) {
                    $es->logger->trace_comment("RUNNING SETUP");
                    for (@$setup) {
                        run_cmd( $_->{do} );
                    }
                }

                $es->logger->trace_comment("RUNNING TESTS: $title");

                subtest $name => sub {
                    plan tests => 0 + @$tests;
                    run_tests( $title, $tests );
                };
                reset_es();
            }
        };
    }
}

#===================================
sub run_tests {
#===================================
    my ( $title, $tests ) = @_;

    fail "Expected an ARRAY of tests, got: " . Dumper($tests)
        unless ref $tests eq 'ARRAY';

    my $val;
    my $i = 0;
    my %stash;

    for (@$tests) {
        my $test_name = "$title " . $i++;
        my ( $type, $test ) = key_val($_);

        if ( $type eq 'do' ) {
            my $catch = delete $test->{catch};
            $test_name .= ": " . ( $catch ? 'catch ' . $catch : 'do' );
            $test = populate_vars( $test, \%stash );
            my $ok = eval { ($val) = run_cmd($test); 1 };
                  $catch ? test_error( $@, $catch, $test_name )
                : $ok    ? pass($test_name)
                :          fail($test_name) || diag($@);
        }
        else {
            my ( $field, $expect );
            if ( ref $test ) {
                ( $field, $expect ) = key_val($test);
            }
            else {
                $field = $test;
            }
            my $got = get_val( $val, $field );
            if ( $type eq 'set' ) {
                $stash{$expect} = $got;
                pass("$test_name: set $expect");
                next;
            }
            $expect = populate_vars( $expect, \%stash );
            $field ||= 'response';
            run_test( "$test_name: $field $type", $type, $expect, $got );
        }
    }
}

#===================================
sub run_test {
#===================================
    my ( $name, $type, $expect, $got ) = @_;
    my $handler = $Test_Types{$type}
        or die "Unknown test type ($type)";
    $handler->( $got, $expect, $name )
        || do {
        $es->logger->trace_comment("FAILED: $name");
        exit if $ENV{BAILOUT};
        };
}

#===================================
sub populate_vars {
#===================================
    my ( $val, $stash ) = @_;

    if ( ref $val eq 'HASH' ) {
        return {
            map { $_ => populate_vars( $val->{$_}, $stash ) }
                keys %$val
        };
    }
    if ( ref $val eq 'ARRAY' ) {
        return [ map { populate_vars( $_, $stash ) } @$val ];
    }
    return undef unless defined $val;
    return 1 if $val eq 'true';
    return 0 if $val eq 'false';
    return $val unless $val =~ /^\$(\w+)/;
    return $stash->{$1};
}

#===================================
sub get_val {
#===================================
    my ( $val, $field ) = @_;
    return undef unless defined $val;
    return $val  unless defined $field;

    for my $next ( split /(?<!\\)\./, $field ) {
        $next =~ s/\\//g;
        if ( ref $val eq 'ARRAY' ) {
            return undef
                unless $next =~ /^\d+$/;
            $val = $val->[$next];
            next;
        }
        if ( ref $val eq 'HASH' ) {
            $val = $val->{$next};
            next;
        }
        last;
    }
    return $val;
}

#===================================
sub run_cmd {
#===================================
    my ( $method, $params ) = key_val(@_);

    $params ||= {};
    my @methods = split /\./, $method;
    my $final   = pop @methods;
    my $obj     = $es;
    for (@methods) {
        $obj = $obj->$_;
    }
    return $wrapper->( $obj->$final(%$params) );
}

#===================================
sub reset_es {
#===================================
    $es->logger->trace_comment("RESETTING");
    $wrapper->( $es->indices->delete( index => '_all', ignore => 404 ) );
}

#===================================
sub key_val {
#===================================
    my $val = shift;
    die "Expected HASH, got: " . Dumper($val)
        unless defined $val
        and ref $val
        and ref $val eq 'HASH';
    die "Expected single key-value pair, got: " . Dumper($val)
        unless keys(%$val) == 1;
    return (%$val);
}

#===================================
sub test_length {
#===================================
    my ( $got, $expected, $name ) = @_;
    if ( ref $got eq 'ARRAY' ) {
        is( @$got + 0, $expected, $name );
    }
    elsif ( ref $got eq 'HASH' ) {
        is( scalar keys(%$got), $expected, $name );
    }
    else {
        is( length($got), $expected, $name );
    }
}

#===================================
sub test_error {
#===================================
    my ( $got, $expect, $name ) = @_;
    if ( $expect =~ m{^/(.+)/$} ) {
        like( $got, qr/$1/, $name );
    }
    else {
        my $class = $Errors{$expect}
            or die "Unknown error type ($expect)";
        is( ref($got) || $got, $class, $name ) || diag($got);
    }
}

#===================================
sub check_skip {
#===================================
    my $title = shift;
    my $cmds  = shift;
    my $skip  = $cmds->[0]{skip} or return;
    shift @$cmds;

    my ( $min, $max ) = split( /\s*-\s*/, $skip->{version} );
    my $current = $wrapper->( $es->info )->{version}{number};

    return
        unless str_version($min) le str_version($current)
        and str_version($max) ge str_version($current);

    my $reason = "Version $current - " . $skip->{reason};

    $es->logger->trace_comment("SKIPPING: $title : $skip");
SKIP: { skip $reason, 1 }
    return 1;
}

#===================================
sub str_version {
#===================================
    no warnings 'uninitialized';
    return sprintf "%03d-%03d-%03d", ( split /\./, shift() )[ 0 .. 2 ];
}
#===================================
sub request_wrapper {
#===================================
    return sub { shift(@_) }
        unless $es->transport->does('Elasticsearch::Role::Is_Async');

    return sub {
        my $promise = shift;
        my $cv      = AE::cv();
        $promise->then( sub { $cv->send( shift @_ ) },
            sub { $cv->croak(@_) } );
        return $cv->recv;
    };
}

1;
