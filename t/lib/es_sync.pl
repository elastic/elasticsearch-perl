use Search::Elasticsearch;
use Test::More;
use strict;
use warnings;

my $trace
    = !$ENV{TRACE}       ? undef
    : $ENV{TRACE} eq '1' ? 'Stderr'
    :                      [ 'File', $ENV{TRACE} ];

my $version = $ENV{ES_VERSION} || '';
my $api
    = $version =~ /^0.90/ ? '0_90::Direct'
    : $version =~ /^1\./  ? '1_0::Direct'
    : $version =~ /^2\./  ? '2_0::Direct'
    :                       '5_0::Direct';
my $body     = $ENV{ES_BODY}     || 'GET';
my $cxn      = $ENV{ES_CXN}      || do "default_cxn.pl" || die( $@ || $! );
my $cxn_pool = $ENV{ES_CXN_POOL} || 'Static';
my $timeout  = $ENV{ES_TIMEOUT}  || 30;
my @plugins = split /,/, ( $ENV{ES_PLUGINS} || '' );
our %Auth;

my $es;
if ( $ENV{ES} ) {
    eval {
        $es = Search::Elasticsearch->new(
            nodes            => $ENV{ES},
            trace_to         => $trace,
            cxn              => $cxn,
            cxn_pool         => $cxn_pool,
            client           => $api,
            send_get_body_as => $body,
            request_timeout  => $timeout,
            plugins          => \@plugins,
            %Auth
        );
        $es->ping unless $ENV{ES_SKIP_PING};
        1;
    } || do {
        diag $@;
        undef $es;
    };
}

unless ($es) {
    plan skip_all => 'No Elasticsearch test node available';
    exit;
}

return $es;
