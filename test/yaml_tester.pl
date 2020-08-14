
#!/usr/bin/env perl

# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

use strict;
use warnings;
use version;
use YAML::XS qw(LoadFile);
#use YAML qw(LoadFile);    
use Test::More;
use Test::Deep;
use Data::Dumper;
use File::Basename;
use Scalar::Util qw(looks_like_number);
use Time::HiRes qw(gettimeofday);
use JSON::PP();
use lib qw(lib t/lib);

local $YAML::XS::Boolean = "JSON::PP";

my $client
    = $ENV{ES_ASYNC}
    ? 'es_async.pl'
    : 'es_sync.pl';

my $es        = do $client or die $!;
my $wrapper   = request_wrapper();
my $skip_list = load_skip_list();

our %Supported = (
    regex            => 1,
    gtelte           => 1,
    stash_in_path    => 1,
    groovy_scripting => sub {
        my $scripting;
        eval {
            $es->index(
                index   => 'test_script',
                type    => 't',
                id      => 1,
                refresh => 1
            );
            $scripting = eval {
                $es->search(
                    body => {
                        script_fields =>
                            { script => { lang => 'groovy', script => 1 } }
                    }
                );
                1;
            };
            $es->indices->delete( index => 'test_script' );
        };
        return $scripting;
    }
);

our %Test_Types = (
    is_true => sub {
        my ( $got, undef, $name ) = @_;
        ok( $got, $name );
    },
    is_false => sub {
        my ( $got, undef, $name ) = @_;
        no warnings 'uninitialized';
        ok( !$got || $got eq 'false', $name );
    },
    lt => sub {
        my ( $got, $expect, $name ) = @_;
        no warnings 'uninitialized';
        ok( $got < $expect, $name )
            or diag "Expected '< $expect', got '$got'";
    },
    gt => sub {
        my ( $got, $expect, $name ) = @_;
        no warnings 'uninitialized';
        ok( $got > $expect, $name )
            or diag "Expected '> $expect', got '$got'";
    },
    lte => sub {
        my ( $got, $expect, $name ) = @_;
        no warnings 'uninitialized';
        ok( $got <= $expect, $name )
            or diag "Expected '<= $expect', got '$got'";
    },
    gte => sub {
        my ( $got, $expect, $name ) = @_;
        no warnings 'uninitialized';
        ok( $got >= $expect, $name )
            or diag "Expected '>= $expect', got '$got'";
    },
    match => sub {
        my ( $got, $expect, $name ) = @_;
        if ( defined $expect and $expect =~ s{^\s*/(.+)/\s*$}{$1}s ) {
            like $got, qr/$expect/x, $name;
        }
        elsif ( looks_like_number($got) and looks_like_number($expect) ) {
            cmp_deeply( $got + 0, num( $expect, 0.0001 ), $name );
        }
        else {
            cmp_deeply(@_);
        }
    },
    length => \&test_length,
    catch  => \&test_error,
);

our %Errors = (
    missing         => 'Search::Elasticsearch::Error::Missing',
    conflict        => 'Search::Elasticsearch::Error::Conflict',
    forbidden       => 'Search::Elasticsearch::Error::Forbidden',
    param           => 'Search::Elasticsearch::Error::Param',
    bad_request     => 'Search::Elasticsearch::Error::Request',
    request         => 'Search::Elasticsearch::Error::Request',
    request_timeout => 'Search::Elasticsearch::Error::RequestTimeout',
    unavailable     => 'Search::Elasticsearch::Error::Unavailable',
);

my $test = shift @ARGV or die "No test specified";
if ( -d $test ) {
    test_dir($test);
} else {
    test_files($test);
}

#===================================
sub test_dir {
#===================================
    my $dir = shift;
    plan tests   => 1;
    subtest $dir => sub {
        my @files = glob "$dir/*.yml";
        foreach my $sub (glob "$dir/*") {
            next unless (-d "$sub");
            push (@files, glob "$sub/*.yml");
        }
        test_files(@files);
    };
}

#===================================
sub test_files {
#===================================
    my @files = @_;

    reset_oss_es();
    if ($ENV{ES} =~ /https/) {
        reset_es();
    }

    plan tests => 0 + @files;

    for my $file (@files) {
        my ($name) = ( $file =~ m{([\w.]+/[\w.]+\.y.?ml)} );
        my ($folder) = ( $file =~ m{([\w]+)/[\w.]+\.y.?ml} );
        if ( $name && ($skip_list->{$name} || $skip_list->{$folder . '/*'}) ) {
            $es->logger->trace_comment("SKIPPING: $name in skip list");
        SKIP: { skip "$name in skip list", 1 }
            next;
        }
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

            my $teardown;
            if ( $teardown = $asts[0]{teardown} ) {
                shift @asts;
            }

            plan tests => 0 + @asts;

            for my $ast (@asts) {

                my ( $title, $tests ) = key_val($ast);
                next if check_skip( $title, $tests );

                if ($setup) {
                    $es->logger->trace_comment("RUNNING SETUP");
                    for (@$setup) {
                        run_cmd( populate_vars( 'request', $_->{do}, {} ) );
                    }
                }

                $es->logger->trace_comment("RUNNING TESTS: $title");

                subtest $title => sub {
                    plan tests => 0 + @$tests;
                    run_tests( $title, $tests );
                };

                if ($teardown) {
                    $es->logger->trace_comment("RUNNING TEARDOWN");
                    for (@$teardown) {
                        run_cmd( populate_vars( 'request', $_->{do}, {} ) );
                    }
                }

                reset_oss_es();
                if ($ENV{ES} =~ /https/) {
                    reset_es();
                }
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
            my $headers = delete $test->{headers};    # ignore headers
            my $catch   = delete $test->{catch};
            $test_name .= ": " . ( $catch ? 'catch ' . $catch : 'do' );
            $test = populate_vars( 'request', $test, \%stash );
            eval { ($val) = run_cmd($test); };
            if ($catch) {
                $val = $@->{vars}{body}
                    if $@ && $@->isa('Search::Elasticsearch::Error');
                test_error( $@, $catch, $test_name );
            }
            elsif ($@) {
                fail($test_name) || diag($@);
            }
            else {
                pass($test_name);
            }
        }
        else {
            my ( $field, $expect );
            if ( ref $test ) {
                ( $field, $expect ) = key_val($test);
            }
            else {
                $field = $test;
            }
            my $got = get_val( $val, $field, \%stash );
            if ( $type eq 'set' ) {
                $stash{$expect} = $got;
                pass("$test_name: set $expect");
                next;
            }
            $got = populate_vars( 'response', $got, {} );
            $expect = populate_vars( 'expect', $expect, \%stash );
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
    my ( $type, $val, $stash ) = @_;

    if ( ref $val eq 'HASH' ) {
        return {
            map { $_ => populate_vars( $type, $val->{$_}, $stash ) }
                keys %$val
        };
    }
    if ( ref $val eq 'ARRAY' ) {
        return [ map { populate_vars( $type, $_, $stash ) } @$val ];
    }
    return undef unless defined $val;
    if ( $type eq 'request' ) {
        return JSON::PP::true()  if $val eq 'true';
        return JSON::PP::false() if $val eq 'false';
        return 0 + $val          if $val =~ /^\d+(?:\.\d+)?$/;
        return undef             if $val eq 'null';
    }
    elsif ( JSON::PP::is_bool($val) ) {
        return $val ? 'true' : 'false';
    }
    return "$val" unless $val =~ /^\$(\w+)/;
    return $stash->{$1};
}

#===================================
sub get_val {
#===================================
    my ( $val, $field, $stash ) = @_;
    return undef unless defined $val;
    return $val  unless defined $field;
    return $val if $field eq '$body';

    for my $next ( split /(?<!\\)\./, $field ) {
        $next =~ s/\\//g;
        $next = populate_vars( 'response', $next, $stash )
            if $next =~ /^\$/;
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
        return undef;
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

    $es->logger->trace_comment( "Start: " . timestamp() );
    my ( $result, $error );
    eval {
        $result = $wrapper->( $obj->$final(%$params) );
        1;
    } or $error = $@;
    $es->logger->trace_comment( "End: " . timestamp() );
    die $error if $error;
    return $result;
}

#===================================
sub reset_oss_es {
#===================================
    $es->logger->trace_comment("RESETTING OSS");
    $es->logger->trace_comment( "Start: " . timestamp() );
    $wrapper->( $es->indices->delete( index => '_all', ignore => 404 ) );
    eval { $wrapper->( $es->indices->delete_template( name => '*' ) ) };
    eval {
        for my $repo ( keys %{ $es->snapshot->get_repository } ) {
            eval {    # ignore url based repos
                my @snaps = map { $_->{snapshot} } @{
                    $es->snapshot->get(
                        repository => $repo,
                        snapshot   => '_all'
                    )->{snapshots}
                };
                for (@snaps) {
                    $es->snapshot->delete(
                        repository => $repo,
                        snapshot   => $_
                    );
                }
            };
            $es->snapshot->delete_repository( repository => $repo );
        }
    };
    $es->logger->trace_comment( "End: " . timestamp() );
}

#===================================
sub reset_es {
#===================================
    my $role;
    my $value;
    my $user;
    my $app;
    my $transform;

    $es->logger->trace_comment("RESETTING");
    $es->logger->trace_comment( "Start: " . timestamp() );

    # Delete all custom roles
    eval {
        my $response = $es->security->get_role();
        while (($role, $value) = each (%$response)) {
            if ( $value->{metadata}->{_reserved} == 0) {
                $es->security->delete_role({ 'name' => $role });
            }
        }
    };

    # Delete all custom users
    eval {
        my $response = $es->security->get_user();
        while (($user, $value) = each (%$response)) {
            if ( $value->{metadata}->{_reserved} == 0) {
                $es->security->delete_user({ 'username' => $user });
            }
        }
    };

    eval {
        my $response = $es->security->get_privileges();
        while (($app, $value) = each (%$response)) {
            if ( $value->{metadata}->{_reserved} == 0) {
                $es->security->delete_user({ 'username' => $user });
            }
        }
    };

    # security.getPrivileges -> security.deletePrivileges
    # ml.getDatafeeds -> ml.deleteDatafeed
    # ml.getJobs -> ml.deleteJob
    # rollup.getJobs -> rollup.stopJob -> rollup.deleteJob
    # tasks.list -> tasks.cancel
    # ilm.removePolicy({ index: '_all' })
    # indices.refresh({ index: '_all' })

    $es->logger->trace_comment( "End: " . timestamp() );
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

    my $reason
        = skip_feature($skip)
        || skip_version($skip)
        || return;

    if ($title && $reason) {
        $es->logger->trace_comment("SKIPPING: $title : $reason");
    }
SKIP: { skip $reason, 1 }
    return 1;
}

#===================================
sub skip_feature {
#===================================
    my $features = shift()->{features} or return;
    $features = [$features] unless ref $features;
    for (@$features) {
        my $supported = $Supported{$_};
        $supported = $supported->() if ref $supported;
        return "Feature not supported: $_"
            unless $supported;
    }
    return;

}

#===================================
sub skip_version {
#===================================
    my $skip    = shift;
    my $version = $skip->{version} or return;
    my $current = $wrapper->( $es->info )->{version}{number};
    return "Version $current - skip all versions"
        if $version eq 'all';

    my ( $min, $max ) = split( /\s*-\s*/, $version );
    $min ||= 0;
    $max ||= 999;
    
    return if version->parse($current) >= version->parse($min)
        and version->parse($current) <= version->parse($max);

    return "Version $current - " . $skip->{reason};
}

#===================================
sub request_wrapper {
#===================================
    return sub { shift(@_) }
        unless $es->transport->does('Search::Elasticsearch::Role::Is_Async');

    return sub {
        my $promise = shift;
        my $cv      = AE::cv();
        $promise->then( sub { $cv->send( shift @_ ) }, sub { $cv->croak(@_) } );
        return $cv->recv;
    };
}

#===================================
sub load_skip_list {
#===================================
    my $v = $wrapper->( $es->info )->{version};
    my $version
        = $v->{build_snapshot} ? $v->{number} . '_SNAPSHOT' : $v->{number};
    my $skip_list = LoadFile("test/skip_list.yaml")->{$version}
        or return {};
    return { map { $_ => 1 } @$skip_list }

}

#===================================
sub timestamp {
#===================================
    my ( $time, $ns ) = gettimeofday;
    my ( $s, $m, $h, $d, $M, $y ) = gmtime($time);
    $M++;
    $y += 1900;
    return sprintf "%d-%02d-%02d %02d:%02d:%02d,%d", $y, $M, $d, $h, $m, $s,
        $ns;
}
1;
