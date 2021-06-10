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
use warnings FATAL => 'all';
use v5.12;
use Path::Class;
use FindBin;
use File::Basename;
use HTTP::Tiny;
use JSON::XS;

do "$FindBin::RealBin/parse_spec_base_74.pl" || die $@;
do "$FindBin::RealBin/../util/get_elasticsearch_info.pl" || die $@;

my $contents = get_elasticsearch_info();
my $dirname = dirname(__FILE__) . "/..";
my $hash = $contents->{version}->{build_hash};

my $pathSpecs = sprintf("%s/util/rest-spec/%s/rest-api-spec/api", $dirname, $hash);

unless (-e $pathSpecs) {
    printf "ERROR: The API spec folder %s is not found", $pathSpecs;
    exit 1;
}
my @files = map { file($_) } (
    sprintf("%s/_common.json", $pathSpecs),
    glob 
        sprintf("%s/*.json", $pathSpecs)
);

forbid(
    'GET' => qw(
        /_nodes/hotthreads
        /_nodes/{node_id}/hotthreads
        )
);

forbid(
    'PUT' => qw(
        /{index}/{type}/_mapping
        )
);

forbid(
    'QS' => qw(
        operation_threading
        field_data
        )
);

process_files( 
    sprintf("%s/lib/Search/Elasticsearch/Client/7_0/Role/API.pm", $dirname),
    @files
);

