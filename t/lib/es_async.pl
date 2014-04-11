#!perl -d
use EV;
use AE;

use Promises backend => ['EV'];
use Search::Elasticsearch::Async;
use Test::More;
use strict;
use warnings;

my $trace
    = !$ENV{TRACE}       ? undef
    : $ENV{TRACE} eq '1' ? 'Stderr'
    :                      [ 'File', $ENV{TRACE} ];

my $cv       = AE::cv;
my $version  = $ENV{ES_VERSION} || '';
my $api      = $version =~ /^0.90/ ? '0_90::Direct' : 'Direct';
my $body     = $ENV{ES_BODY} || 'GET';
my $cxn      = $ENV{ES_CXN} || do "default_async_cxn.pl" || die $!;
my $cxn_pool = $ENV{ES_CXN_POOL} || 'Async::Static';

if ( $cxn eq 'Mojo' && !eval { require 'Mojo::UserAgent'; 1 } ) {
    plan skip_all => 'Mojo::UserAgent not installed';
    exit;
}

my $es;
if ( $ENV{ES} ) {
    $es = Search::Elasticsearch::Async->new(
        nodes            => $ENV{ES},
        trace_to         => $trace,
        cxn              => $cxn,
        cxn_pool         => $cxn_pool,
        client           => $api,
        send_get_body_as => $body
    );
    $es->ping->then( sub { $cv->send(@_) }, sub { $cv->croak(@_) } );
    eval { $cv->recv } or do {
        diag $@;
        undef $es;
    };
}

unless ($es) {
    plan skip_all => 'No Elasticsearch test node available';
    exit;
}

return $es;

