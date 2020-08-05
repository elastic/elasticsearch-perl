# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;

use Search::Elasticsearch::Async;

my $s = Search::Elasticsearch::Async->new()->transport->serializer->JSON;

SKIP: {
    skip 'Cpanel::JSON::XS not installed' => 1
        unless eval { require Cpanel::JSON::XS; 1 };

    isa_ok $s, "Cpanel::JSON::XS", 'Cpanel';
}

done_testing;

