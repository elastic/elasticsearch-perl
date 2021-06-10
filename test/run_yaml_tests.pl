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
use lib qw(lib t/lib);
use File::Basename;
use FindBin;
use TAP::Harness;
use Getopt::Long;

my $verbose = 0;
my $trace   = 0;
my $async   = 0;
my $cxn     = '';
my $junit   = 0;
my @plugins;

do "$FindBin::RealBin/../util/get_elasticsearch_info.pl" || die $@;
my $contents = get_elasticsearch_info();
my $hash = $contents->{version}->{build_hash};
my $testPath = sprintf ("%s/../util/rest-spec/%s/rest-api-spec/test", dirname(__FILE__), $hash);

unless (-e $testPath) {
    printf "The rest-spec path %s does not exists!\n", $testPath;
    printf "You need to execute util/checkout_yaml_test.pl first.\n";
    exit 1;
}

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
    @tests =  grep {-d} glob(sprintf("%s/%s/*", $testPath, $ENV{TEST_SUITE}));
}

# [$file,$name]
@tests = map { [ $_ =~ m{(.+/([^/]+))} ] } @tests;

my $agg = $tap->runtests(@tests);

exit $agg->has_errors;
