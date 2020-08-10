# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use lib 't/lib';

if ($ENV{ES} =~ /https/) {
    plan skip_all => 'Hijk does not support SSL';
}
$ENV{ES_VERSION} = '6_0';
$ENV{ES_CXN} = 'Hijk';
do "es_sync_fork.pl" or die( $@ || $! );
