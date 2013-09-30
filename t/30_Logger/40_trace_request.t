use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
do 'LogCallback.pl';

isa_ok my $e = Elasticsearch->new( nodes => 'https://foo.bar:444/some/path' ),
    'Elasticsearch::Client::Direct',
    'Client';

isa_ok my $l = $e->logger, 'Elasticsearch::Logger::LogAny', 'Logger';
my $c = $e->transport->cxn_pool->cxns->[0];
ok $c->does('Elasticsearch::Role::Cxn'), 'Does Elasticsearch::Role::Cxn';

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
curl -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=1'
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
    }
    ),
    'Body';

is $format, <<'REQUEST', 'Body - format';
# Request to: https://foo.bar:444/some/path
curl -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=1' -d '
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
    }
    ),
    'Bulk';

is $format, <<'REQUEST', 'Bulk - format';
# Request to: https://foo.bar:444/some/path
curl -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=1' -d '
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
    }
    ),
    'Body string';

is $format, <<'REQUEST', 'Body string - format';
# Request to: https://foo.bar:444/some/path
curl -XPOST 'http://localhost:9200/xyz?foo=bar&pretty=1' -d '
The quick brown fox
jumped over the lazy dog\u0027s basket'
REQUEST

done_testing;

