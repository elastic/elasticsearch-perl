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

my $cv = AE::cv;
my $version = $ENV{ES_VERSION} || '';
my $api
    = $version =~ /^0.90/ ? '0_90::Direct'
    : $version =~ /^1\./  ? '1_0::Direct'
    : $version =~ /^2\./  ? '2_0::Direct'
    :                       '5_0::Direct';
my $body     = $ENV{ES_BODY}     || 'GET';
my $cxn      = $ENV{ES_CXN}      || do "default_async_cxn.pl" || die( $@ || $! );
my $cxn_pool = $ENV{ES_CXN_POOL} || 'Async::Static';
my @plugins = split /,/, ( $ENV{ES_PLUGINS} || '' );
our %Auth;

if ( $cxn eq 'Mojo' && !eval { require Mojo::UserAgent; 1 } ) {
    plan skip_all => 'Mojo::UserAgent not installed';
    exit;
}

{
    no warnings 'redefine';

#===================================
    sub wait_for {
#===================================
        my $promise = shift;
        my $cv      = AE::cv;
        $promise->done( $cv, sub { $cv->croak(@_) } );
        $cv->recv;
    }
}

my $es;
if ( $ENV{ES} ) {
    eval {
        $es = Search::Elasticsearch::Async->new(
            nodes            => $ENV{ES},
            trace_to         => $trace,
            cxn              => $cxn,
            cxn_pool         => $cxn_pool,
            client           => $api,
            send_get_body_as => $body,
            plugins          => \@plugins,
            %Auth
        );
        if ( $ENV{ES_SKIP_PING} ) {
            $cv->send(1);
        }
        else {
            $es->ping->then( sub { $cv->send(@_) }, sub { $cv->croak(@_) } );
        }
        $cv->recv;
        1;
    } or do {
        diag $@;
        undef $es;
    };
}

unless ($es) {
    plan skip_all => 'No Elasticsearch test node available';
    exit;
}

return $es;

