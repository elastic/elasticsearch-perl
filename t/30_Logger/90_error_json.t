# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More tests => 3;
use Test::Exception;
use lib 't/lib';

use_ok('Search::Elasticsearch::Error');

eval 'use JSON::PP;';
SKIP: {
    skip 'JSON::PP module not installed', 2 if $@;
    ok( my $es_error = Search::Elasticsearch::Error->new(
            'Missing',
            "Foo missing",
            { code => 404 }
        ),
        'Create test error'
    );
    like(
        JSON::PP->new->convert_blessed(1)->encode( { eserr => $es_error } ),
        qr/Foo missing/,
        'encode_json',
    );
}
