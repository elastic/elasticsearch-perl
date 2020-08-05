# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;

BEGIN {
    eval { require JSON::XS; 1 } or do {
        plan skip_all => 'JSON::XS not installed';
        done_testing;
        exit;
        }
}

use Search::Elasticsearch;

my $s = Search::Elasticsearch->new()->transport->serializer->JSON;
isa_ok $s, "JSON::XS", 'JSON::XS';

done_testing;

