#!/usr/bin/env perl

# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use strict;
use warnings;
use lib qw(lib t/lib);

use TAP::Harness;
use Getopt::Long;

my $verbose = 0;
my $trace   = 0;
my $async   = 0;
my $cxn     = '';
my $junit   = 0;
my @plugins;

GetOptions(
    'verbose'  => \$verbose,
    'trace=s'  => \$trace,
    'cxn=s'    => \$cxn,
    'async'    => \$async,
    'junit'    => \$junit,
    'plugin=s' => \@plugins
);

my $harness = 'TAP::Harness';
if ($junit) {
    require TAP::Harness::JUnit;
    $harness = 'TAP::Harness::JUnit';
}

$ENV{ES_ASYNC} = $async;
$ENV{ES_CXN}   = $cxn;
$ENV{TRACE}    = $trace;
$ENV{ES_PLUGINS} = join ",", @plugins;

my $tap = $harness->new(
    {   exec      => [ $^X, 'test/yaml_tester.pl' ],
        verbosity => $verbose,
        color     => 1,
    }
);

my @tests = @ARGV;
if (@tests) {
    @tests = grep { -d || /\.ya?ml$/ } @tests;
} else {
    if ($ENV{TEST_SUITE} eq "oss") { 
        @tests = grep {-d} glob("elasticsearch/rest-api-spec/src/main/resources/rest-api-spec/test/*");
        $ENV{ES} = $ENV{ELASTICSEARCH_URL} || 'http://localhost:9200';
    } else {
        @tests = grep {-d} glob("elasticsearch/x-pack/plugin/src/test/resources/rest-api-spec/test/*");
        $ENV{ES} = $ENV{ELASTICSEARCH_URL} || 'https://elastic:changeme@localhost:9200';
    }
}

# [$file,$name]
@tests = map { [ $_ =~ m{(.+/([^/]+))} ] } @tests;

my $agg = $tap->runtests(@tests);

exit $agg->has_errors;
