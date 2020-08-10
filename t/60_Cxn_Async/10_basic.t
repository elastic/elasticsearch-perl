# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Search::Elasticsearch::Async;

my $c = Search::Elasticsearch::Async->new->transport->cxn_pool->cxns->[0];
ok $c->does('Search::Elasticsearch::Role::Cxn::Async'),
    'Does Search::Elasticsearch::Role::Cxn::Async';

# MARK LIVE

$c->mark_live;

ok $c->is_live,       "Cxn is live";
is $c->ping_failures, 0, "No ping failures";
is $c->next_ping,     0, "No ping scheduled";

# MARK DEAD

$c->mark_dead;

ok $c->is_dead, "Cxn is dead";
is $c->ping_failures, 1, "Has ping failure";
ok $c->next_ping > time(), "Ping scheduled";
ok $c->next_ping <= time() + $c->dead_timeout, "Dead timeout x 1";

$c->mark_dead;
ok $c->is_dead, "Cxn still dead";
is $c->ping_failures, 2, "Has 2 ping failures";
ok $c->next_ping > time(), "Ping scheduled";
ok $c->next_ping <= time() + 2 * $c->dead_timeout, "Dead timeout x 2";

$c->mark_dead for 1 .. 100;
ok $c->is_dead, "Cxn still dead";
is $c->ping_failures, 102, "Has 102 ping failures";
ok $c->next_ping > time(), "Ping scheduled";
ok $c->next_ping <= time() + $c->max_dead_timeout, "Max dead timeout";

# FORCE PING

$c->force_ping;
ok $c->is_dead,       "Cxn is dead after force ping";
is $c->ping_failures, 0, "Force ping has no ping failures";
is $c->next_ping,     -1, "Next ping scheduled for now";

done_testing;
