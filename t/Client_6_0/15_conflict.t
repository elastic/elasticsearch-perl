use Test::More;
use strict;
use warnings;
use lib 't/lib';

$ENV{ES_VERSION} = '6_0';
my $es = do "es_sync.pl" or die( $@ || $! );

$es->indices->delete( index => '_all' );

$es->index( index => 'test', type => 'test', id => 1, body => {} );

my $error;

eval {
    $es->index(
        index   => 'test',
        type    => 'test',
        id      => 1,
        body    => {},
        version => 2
    );
    1;
} or $error = $@;

ok $error->is('Conflict'), 'Conflict Exception';
is $error->{vars}{current_version}, 1, "Error has current version v1";

done_testing;
