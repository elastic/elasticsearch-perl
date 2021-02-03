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

if ($ENV{TEST_SUITE} eq "free") { 
    $ENV{ES} = $ENV{ELASTICSEARCH_URL} || 'http://localhost:9200';
} else {
    $ENV{ES} = $ENV{ELASTICSEARCH_URL} || 'https://elastic:changeme@localhost:9200';
}

my $response = HTTP::Tiny->new->get($ENV{ES}) or die "The server $ENV{ES} is not running!";

my $contents = decode_json $response->{content} or die "The JSON response is not valid!";
my $hash = $contents->{version}->{build_hash};

`cd elasticsearch; git checkout $hash`;
