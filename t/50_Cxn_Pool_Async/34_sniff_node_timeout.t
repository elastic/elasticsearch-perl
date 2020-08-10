# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Test::Exception;
use Search::Elasticsearch::Async;
use lib 't/lib';
use MockAsyncCxn qw(mock_sniff_client);

## Sniff after Timeout error

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, sniff => [ 'one', 'two' ] },
    { node => 3, code => 200, content => 1 },
    { node => 4, code => 509, error   => 'Timeout' },

    # throws Timeout

    { node => 3, sniff => ['one'] },
    { node => 4, sniff => ['one'] },
    { node => 5, code  => 200, content => 1 },
    { node => 5, code  => 200, content => 1 },

    # force sniff
    { node => 5, sniff => [ 'one', 'two' ] },
    { node => 6, code => 200, content => 1 },
    { node => 7, code => 200, content => 1 },
);

ok $t->perform_sync_request()
    && !eval { $t->perform_sync_request }
    && $@ =~ /Timeout/
    && $t->perform_sync_request
    && $t->perform_sync_request
    && $t->cxn_pool->schedule_check
    && $t->perform_sync_request
    && $t->perform_sync_request,
    'Sniff after timeout';

done_testing;
