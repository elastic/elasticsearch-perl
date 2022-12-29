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

my $outputDir = dirname(__FILE__) . "/rest-spec";
my $version = $ENV{STACK_VERSION};

my $artifact = sprintf("rest-resources-zip-%s.zip", $version);
my $tempFilePath = sprintf("%s/%s.zip", get_tempdir(), $version);

unless (-e $tempFilePath) {
    # Download of Elasticsearch rest-api artifacts
    my $json = get "https://artifacts-api.elastic.co/v1/versions/$version";
    if ($json eq "") {
        printf "ERROR: I cannot download the artifcats from https://artifacts-api.elastic.co/v1/versions/%s\n", $version;
        exit 1;
    }
    my $content = decode_json $json or die "The JSON response is not valid!";
    
    foreach my $build (@{$content->{version}->{builds}}) {
        printf "Download %s\n", $build->{projects}->{elasticsearch}->{packages}->{$artifact}->{url};
        system(sprintf("wget -q -O $tempFilePath %s", $build->{projects}->{elasticsearch}->{packages}->{$artifact}->{url})) == 0
            or die "ERROR: failed to download $artifact\n";
        last;
    }
} else {
    printf("The file %s already exists\n", $tempFilePath);
}
unless (-e $tempFilePath) {
    printf "ERROR: the ES version %s has not been found\n", $version;
    exit 1;
}

unless (-e $outputDir) {
    mkdir($outputDir);
}
unless (-e sprintf("%s/%s", $outputDir, $version)) {
    system(sprintf("unzip -qq %s -d %s/%s", $tempFilePath, $outputDir, $version)) == 0
        or die "ERROR: unable to unzip $tempFilePath\n";
} else {
    printf "Folder %s/%s already exists\n", $outputDir, $version;
}
printf "Elasticsearch REST API specification installed successfully!\n";
