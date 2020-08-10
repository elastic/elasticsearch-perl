# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Test::Exception;
use Search::Elasticsearch;
use lib 't/lib';
use MockCxn qw(mock_sniff_client);

## For whatever reason, sniffing returns bad data

my $t = mock_sniff_client(
    { nodes => ['one'] },
    { node  => 1, code => 200, content => '{"nodes":{"one":{}}}' },

    # throw NoNodes
);

ok !eval { $t->perform_request }
    && $@ =~ /NoNodes/,
    "Missing http_address";

done_testing;
