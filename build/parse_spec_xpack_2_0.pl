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

my @files
    = map { file($_) }
    glob
    '../x-plugins/elasticsearch/x-pack/*/src/test/resources/rest-api-spec/api/*.json';

process_files( 'lib/Search/Elasticsearch/Plugin/XPack/2_0/Role/API.pm', @files );
