#!/usr/bin/env perl

# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use strict;
use warnings FATAL => 'all';
use v5.12;
use Path::Class;
use FindBin;

do "$FindBin::RealBin/parse_spec_base.pl" || die $@;

my @oss = map { file($_) } (
    '../elasticsearch/rest-api-spec/src/main/resources/rest-api-spec/api/_common.json',
    glob
        '../elasticsearch/rest-api-spec/src/main/resources/rest-api-spec/api/*.json'
);

my @xpack = map { file($_) } (
    glob
        '../elasticsearch/x-pack/plugin/src/test/resources/rest-api-spec/api/*.json'
);

my @files = (@oss, @xpack);

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

process_files( '../lib/Search/Elasticsearch/Client/7_0/Role/API.pm', @files );

