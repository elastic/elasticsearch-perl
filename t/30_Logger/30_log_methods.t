use Test::More;
use Test::Exception;
use Search::Elasticsearch;
use lib 't/lib';
do 'LogCallback.pl';

isa_ok my $l = Search::Elasticsearch->new->logger,
    'Search::Elasticsearch::Logger::LogAny',
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
    ( $method, $format ) = ();
    ok $l->$level("foo"), "$level";
    is $method, $level, "$level - method";
    is $format, "foo", "$level - format";

    # ->debugf
    ( $method, $format ) = ();
    ok $l->$levelf( "foo %s", "bar", 42 ), "$levelf";
    is $method, $level, "$levelf - method";
    is $format, "foo bar", "$levelf - format";

    # ->is_debug
    ( $method, $format ) = ();
    ok $l->$is_level(), "$is_level";
    is $method, $is_level, "$is_level - method";
    is $format, undef, "$is_level - format";
}

#===================================
sub test_throw {
#===================================
    my $level = shift;
    my $throw = 'throw_' . $level;
    my $re    = qr/\[Request\] \*\* Foo/;
    ( $method, $format ) = ();

    throws_ok { $l->$throw( 'Request', 'Foo', 42 ) } $re, $throw;

    is $@->{vars}, 42, "$throw - vars";
    is $method,   $level, "$throw - method";
    like $format, $re,    "$throw - format";

}
