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
