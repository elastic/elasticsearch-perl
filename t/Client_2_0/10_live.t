use Test::More;
use Test::Deep;
use Test::Exception;
use strict;
use warnings;
use lib 't/lib';

my $es;
$ENV{ES_VERSION} = '2_0';
local $ENV{ES_CXN_POOL};

$ENV{ES_CXN_POOL} = 'Static';
$es = do "es_sync.pl" or die( $@ || $! );
is $es->info->{tagline}, "You Know, for Search", 'CxnPool::Static';

$ENV{ES_CXN_POOL} = 'Static::NoPing';
$es = do "es_sync.pl" or die( $@ || $! );
is $es->info->{tagline}, "You Know, for Search", 'CxnPool::Static::NoPing';

$ENV{ES_CXN_POOL} = 'Sniff';
$es = do "es_sync.pl" or die( $@ || $! );
is $es->info->{tagline}, "You Know, for Search", 'CxnPool::Sniff';

my ($node) = values %{ $es->transport->cxn_pool->next_cxn->sniff };
ok $node->{http}{max_content_length_in_bytes}, 'Sniffs max_content length';

done_testing;
