# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use strict;
use warnings;
use lib 't/lib';

$ENV{ES_VERSION} = '1_0';
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
