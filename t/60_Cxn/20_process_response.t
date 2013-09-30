use Test::More;
use Test::Exception;
use Test::Deep;
use Elasticsearch;

my $c = Elasticsearch->new->transport->cxn_pool->cxns->[0];
ok $c->does('Elasticsearch::Role::Cxn'), 'Does Elasticsearch::Role::Cxn';

my ( $code, $response );

### OK GET
( $code, $response )
    = $c->process_response( { method => 'GET', ignore => [] },
    200, "OK", '{"ok":1}' );

is $code, 200, "OK GET - code";
cmp_deeply $response, { ok => 1 }, "OK GET - body";

### OK GET - Text body
( $code, $response )
    = $c->process_response( { method => 'GET', ignore => [] },
    200, "OK", 'Foo' );

is $code,             200,   "OK GET Text body - code";
cmp_deeply $response, 'Foo', "OK GET Text body - body";

### OK GET - Empty body
( $code, $response )
    = $c->process_response( { method => 'GET', ignore => [] },
    200, "OK", '' );

is $code,             200, "OK GET Empty body - code";
cmp_deeply $response, '',  "OK GET Empty body - body";

### OK HEAD
( $code, $response )
    = $c->process_response( { method => 'HEAD', ignore => [] }, 200, "OK" );

is $code,     200, "OK HEAD - code";
is $response, 1,   "OK HEAD - body";

### Missing GET
throws_ok {
    $c->process_response( { method => 'GET', ignore => [] },
        404, "Missing", '{"error": "Something is missing"}' );
}
qr/Missing/, "Missing GET";

### Missing GET ignore
( $code, $response )
    = $c->process_response( { method => 'GET', ignore => [404] },
    404, "Missing", '{"error": "Something is missing"}' );

is $code,     404,   "Missing GET - code";
is $response, undef, "Missing GET - body";

### Missing HEAD
( $code, $response )
    = $c->process_response( { method => 'HEAD', ignore => [] },
    404, "Missing" );
is $code,     404,   "Missing HEAD - code";
is $response, undef, "Missing HEAD - body";

### Request error
throws_ok {
    $c->process_response( { method => 'GET', ignore => [] },
        400, "Request", '{"error":"error in body"}' );
}
qr/\[400\] error in body/, "Request error";

### Conflict error
throws_ok {
    $c->process_response( { method => 'GET', ignore => [] }, 409, "Conflict",
        '{"status" : 409,"error" : "VersionConflictEngineException[[test][2] [test][1]: version conflict, current [1], provided [2]]"}'
    );
}
qr/\[409\] VersionConflictEngineException/, "Conflict error";
is $@->{vars}{current_version}, 1, "Error has current version";

### Timeout error
throws_ok {
    $c->process_response( { method => 'GET', ignore => [] },
        509, "28: Timed out,read timeout" );
}
qr/Timeout/, "Timeout error";

done_testing;

