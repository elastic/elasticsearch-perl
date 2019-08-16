#!/usr/bin/env perl

use strict;
use warnings;
use LWP::Simple;
use JSON::PP;

my $contents = get("http://" . $ENV{ES}) or die "The server $ENV{ES} is not running!";

$contents = decode_json $contents or die "The JSON response is not valid!";
my $hash = $contents->{version}->{build_hash};

`cd elasticsearch; git checkout $hash`;
