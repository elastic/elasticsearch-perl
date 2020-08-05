# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Test::Exception;
use Search::Elasticsearch;

do './t/lib/LogCallback.pl' or die( $@ || $! );

ok my $e
    = Search::Elasticsearch->new( nodes => 'https://foo.bar:444/some/path' ),
    'Client';

isa_ok my $l = $e->logger, 'Search::Elasticsearch::Logger::LogAny', 'Logger';
my $c = $e->transport->cxn_pool->cxns->[0];
ok $c->does('Search::Elasticsearch::Role::Cxn'),
    'Does Search::Elasticsearch::Role::Cxn';

# No body

ok $l->trace_response( $c, 200, undef, 0.123 ), 'No body';

is $format, <<"RESPONSE", 'No body - format';
# Response: 200, Took: 123 ms
#\x20
RESPONSE

# Body

ok $l->trace_response( $c, 200, { foo => 'bar' }, 0.123 ), 'Body';
is $format, <<'RESPONSE', 'Body - format';
# Response: 200, Took: 123 ms
# {
#    "foo" : "bar"
# }
RESPONSE

done_testing;

