#!/usr/bin/env perl

use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

if ($ENV{TEST_SUITE} eq "free") { 
    $ENV{ES} = $ENV{ELASTICSEARCH_URL} || 'http://localhost:9200';
} else {
    $ENV{ES} = $ENV{ELASTICSEARCH_URL} || 'https://elastic:changeme@localhost:9200';
}

my $response = HTTP::Tiny->new->get($ENV{ES}) or die "The server $ENV{ES} is not running!";

my $contents = decode_json $response->{content} or die "The JSON response is not valid!";
my $hash = $contents->{version}->{build_hash};

`cd elasticsearch; git checkout $hash`;
