#!/usr/bin/env perl

use strict;
use warnings;
use lib qw(
    perl/lib
    perl-async/lib
    perl/t/lib
    perl-async/t/lib
    ../promises-perl/lib
);

use TAP::Harness;
use Getopt::Long;

my $verbose = 0;
my $trace   = 0;
my $async   = 0;
my $cxn     = '';

GetOptions(
    'verbose' => \$verbose,
    'trace'   => \$trace,
    'cxn=s'   => \$cxn,
    'async'   => \$async,
);

$ENV{ES_ASYNC} = $async;
$ENV{ES_CXN}   = $cxn;
$ENV{TRACE}    = $trace;
$ENV{ES}       = "localhost:9200";

my $tap = TAP::Harness->new(
    {   exec      => [ $^X, 'test/yaml_tester.pl' ],
        verbosity => $verbose,
        color     => 1,
    }
);

my @tests = @ARGV;
if (@tests) {
    @tests = grep { -d || /\.yaml$/ } @tests;
}
else {
    @tests = grep {-d} glob("elasticsearch/rest-api-spec/test/*");
}

# [$file,$name]
@tests = map { [ $_ =~ m{(.+/([^/]+))} ] } @tests;

my $agg = $tap->runtests(@tests);

exit $agg->has_errors;

