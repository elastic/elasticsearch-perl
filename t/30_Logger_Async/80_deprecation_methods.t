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
