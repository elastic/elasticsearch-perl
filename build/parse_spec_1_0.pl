#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use v5.12;
use Path::Class;
use FindBin;

do "$FindBin::RealBin/parse_spec_base.pl" || die $?;

my @api_dirs = qw(rest-api-spec/api);
my @files
    = map { file($_) } map { glob "../elasticsearch/$_/*.json" } @api_dirs;

forbid(
    'GET' => qw(
        /_nodes/hotthreads
        /_nodes/{node_id}/hotthreads
        /_nodes/{metric}
        )
);

forbid(
    'PUT' => qw(
        /{index}/{type}/_mapping
        )
);

forbid(
    'DELETE' => qw(
        /{index}/{type}
        /{index}/{type}/_mapping
        )
);

forbid(
    'QS' => qw(
        operation_threading
        field_data
        )
);

process_files( 'lib/Search/Elasticsearch/Client/1_0/Role/API.pm', @files );

