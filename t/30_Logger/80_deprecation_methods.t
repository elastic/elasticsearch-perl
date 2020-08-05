# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Test::Exception;
use Search::Elasticsearch;

do './t/lib/LogCallback.pl' or die( $@ || $! );

isa_ok my $l = Search::Elasticsearch->new->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Logger';

( $method, $format ) = ();
ok $l->deprecation( "foo", { foo => 1 } ), "deprecation";
is $method, "warning", "deprecation - method";
is $format, "[DEPRECATION] foo - In request: {foo => 1}", "deprecation - format";

done_testing;
