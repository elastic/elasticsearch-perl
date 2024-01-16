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
use HTTP::Tiny;
use JSON::PP;
use File::Util::Tempdir qw(get_tempdir);
use File::Basename;
use FindBin;
use IO::Uncompress::Unzip qw(unzip $UnzipError) ;
use LWP::Simple qw(get);
use Data::Dumper;

do "$FindBin::RealBin/get_elasticsearch_info.pl" || die $@;

my $contents = get_elasticsearch_info();
my $outputDir = dirname(__FILE__) . "/rest-spec";
my $hash = $contents->{version}->{build_hash};

my $version = $contents->{version}->{number};
my $artifact = sprintf("rest-resources-zip-%s.zip", $version);
my $tempFilePath = sprintf("%s/%s.zip", get_tempdir(), $hash);

unless (-e $tempFilePath) {
    # Download of Elasticsearch rest-api artifacts
    my $json = get "https://artifacts-api.elastic.co/v1/versions/$version";

    if ($json eq "") {
        printf "ERROR: I cannot download the artifcats from https://artifacts-api.elastic.co/v1/versions/%s\n", $version;
        exit 1;
    }
    my $content = decode_json $json or die "The JSON response is not valid!";
    printf "HASH: %s\n", $hash;
    
    foreach my $build (@{$content->{version}->{builds}}) {
        if ($build->{projects}->{elasticsearch}->{commit_hash} eq $hash) {
            printf "Download %s\n", $build->{projects}->{elasticsearch}->{packages}->{$artifact}->{url};
            system(sprintf("wget -q -O $tempFilePath %s", $build->{projects}->{elasticsearch}->{packages}->{$artifact}->{url})) == 0
                or die "ERROR: failed to download $artifact\n";
            last;
        }
    }
} else {
    printf("The file %s already exists\n", $tempFilePath);
}
unless (-e $tempFilePath) {
    printf "ERROR: the commit_hash %s has not been found\n", $hash;
    exit 1;
}

unless (-e $outputDir) {
    mkdir($outputDir);
}
unless (-e sprintf("%s/%s", $outputDir, $hash)) {
    system(sprintf("unzip -qq %s -d %s/%s", $tempFilePath, $outputDir, $hash)) == 0
        or die "ERROR: unable to unzip $tempFilePath\n";
} else {
    printf "Folder %s/%s already exists\n", $outputDir, $hash;
}
printf "Rest-spec API installed successfully!\n";
