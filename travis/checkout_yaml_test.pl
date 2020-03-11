#!/usr/bin/env perl

use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

my $response = HTTP::Tiny->new->get($ENV{ES}) or die "The server $ENV{ES} is not running!";

my $contents = decode_json $response->{content} or die "The JSON response is not valid!";
my $hash = $contents->{version}->{build_hash};

`cd elasticsearch; git checkout $hash`;
