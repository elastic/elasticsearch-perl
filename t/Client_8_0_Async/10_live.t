# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

use Test::More;
use Test::Deep;
use Test::Exception;
use AE;
use strict;
use warnings;
use lib 't/lib';

$ENV{ES_VERSION} = '8_0';

my $es;
local $ENV{ES_CXN_POOL};

$ENV{ES_CXN_POOL} = 'Async::Static';
$es = do "es_async.pl" or die( $@ || $! );

is wait_for( $es->info )->{tagline}, "You Know, for Search",
    'CxnPool::Async::Static';

$ENV{ES_CXN_POOL} = 'Async::Static::NoPing';
$es = do "es_async.pl" or die( $@ || $! );
is wait_for( $es->info )->{tagline}, "You Know, for Search",
    'CxnPool::Async::Static::NoPing';

$ENV{ES_CXN_POOL} = 'Async::Sniff';
$es = do "es_async.pl" or die( $@ || $! );
is wait_for( $es->info )->{tagline}, "You Know, for Search",
    'CxnPool::Async::Sniff';

my ($node) = values %{
    (   wait_for(
            $es->transport->cxn_pool->next_cxn->then(
                sub { shift()->sniff }
            )
        )
    )[1]
};
ok $node->{http}{max_content_length_in_bytes}, 'Sniffs max_content length';

done_testing;

