use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
do 'LogCallback.pl';

isa_ok my $l = Elasticsearch->new->logger, 'Elasticsearch::Logger::LogAny',
    'Logger';

test_level($_) for qw(debug info warning error critical trace);
test_throw($_) for qw(error critical);

done_testing;

#===================================
sub test_level {
#===================================
    my $level    = shift;
    my $levelf   = $level . 'f';
    my $is_level = 'is_' . $level;

    # ->debug
    ( $method, $format, @params ) = ();
    ok $l->$level( "foo", 42 ), "$level";
    is $method, $level, "$level - method";
    is $format, "foo", "$level - format";
    is $params[0], 42, "$level - params";

    # ->debugf
    ( $method, $format, @params ) = ();
    ok $l->$levelf( "foo %s", "bar", 42 ), "$levelf";
    is $method, $level, "$levelf - method";
    is $format, "foo bar", "$levelf - format";
    is scalar @params, 0, "$levelf - params";

    # ->is_debug
    ( $method, $format, @params ) = ();
    ok $l->$is_level(), "$is_level";
    is $method, $is_level, "$is_level - method";
    is $format, undef, "$is_level - format";
    is scalar @params, 0, "$is_level - params";

}

#===================================
sub test_throw {
#===================================
    my $level = shift;
    my $throw = 'throw_' . $level;
    my $re    = qr/\[Request\] \*\* Foo/;
    ( $method, $format, @params ) = ();

    throws_ok { $l->$throw( 'Request', 'Foo', 42 ) } $re, $throw;

    is $@->{vars}, 42, "$throw - vars";
    is $method,   $level, "$throw - method";
    like $format, $re,    "$throw - format";
    is scalar @params, 0, "$throw - params";

}
