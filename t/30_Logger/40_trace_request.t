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

ok $l->trace_request(
    $c,
    {   method    => 'POST',
        qs        => { foo => 'bar' },
        serialize => 'std',
        path      => '/xyz'
    }
    ),
    'No body';

is $format, <<'REQUEST', 'No body - format';
# Request to: https://foo.bar:444/some/path
curl -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=true'
REQUEST

# Std body

ok $l->trace_request(
    $c,
    {   method    => 'POST',
        qs        => { foo => 'bar' },
        serialize => 'std',
        path      => '/xyz',
        body      => { foo => qq(bar\n'baz) },
        data      => qq({"foo":"bar\n'baz"}),
        mime_type => 'application/json',
    }
    ),
    'Body';

is $format, <<'REQUEST', 'Body - format';
# Request to: https://foo.bar:444/some/path
curl -H "Content-type: application/json" -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=true' -d '
{
   "foo" : "bar\n\u0027baz"
}
'
REQUEST

# Bulk body

ok $l->trace_request(
    $c,
    {   method    => 'POST',
        qs        => { foo => 'bar' },
        serialize => 'bulk',
        path      => '/xyz',
        body      => [ { foo => qq(bar\n'baz) }, { foo => qq(bar\n'baz) } ],
        data => qq({"foo":"bar\\n\\u0027baz"}\n{"foo":"bar\\n\\u0027baz"}\n),
        mime_type => 'application/json',
    }
    ),
    'Bulk';

is $format, <<'REQUEST', 'Bulk - format';
# Request to: https://foo.bar:444/some/path
curl -H "Content-type: application/json" -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=true' -d '
{"foo":"bar\n\u0027baz"}
{"foo":"bar\n\u0027baz"}
'
REQUEST

# String body

ok $l->trace_request(
    $c,
    {   method    => 'POST',
        qs        => { foo => 'bar' },
        serialize => 'std',
        path      => '/xyz',
        body => qq(The quick brown fox\njumped over the lazy dog's basket),
        mime_type => 'application/json',
    }
    ),
    'Body string';

is $format, <<'REQUEST', 'Body string - format';
# Request to: https://foo.bar:444/some/path
curl -H "Content-type: application/json" -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=true' -d '
The quick brown fox
jumped over the lazy dog\u0027s basket'
REQUEST

done_testing;

