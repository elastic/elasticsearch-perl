use Elasticsearch;
use Test::More;
use strict;
use warnings;

my $trace
    = !$ENV{TRACE}       ? undef
    : $ENV{TRACE} eq '1' ? 'Stderr'
    :                      [ 'File', $ENV{TRACE} ];

my $version = $ENV{ES_VERSION} || '';
my $api = $version =~ /^0.90/ ? '0_90::Direct' : 'Direct';
my $body = $ENV{ES_BODY} || 'GET';
my $cxn = $ENV{ES_CXN} || do "default_cxn.pl" || die $!;

my $es;
if ( $ENV{ES} ) {
    $es = Elasticsearch->new(
        nodes            => $ENV{ES},
        trace_to         => $trace,
        cxn              => $cxn,
        client           => $api,
        send_get_body_as => $body
    );
    eval { $es->ping; } or do {
        diag $@;
        undef $es;
    };
}

unless ($es) {
    plan skip_all => 'No Elasticsearch test node available';
    exit;
}

return $es;
