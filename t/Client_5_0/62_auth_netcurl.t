use lib 't/lib';

$ENV{ES_VERSION} = '5_0';
$ENV{ES_CXN} = 'NetCurl';
use Net::Curl::Easy qw(
    CURLOPT_CAINFO
);

our $Throws_SSL = "SSL";

sub ssl_options {
    return { CURLOPT_CAINFO() => $_[0] };
}

do "es_sync_auth.pl" or die( $@ || $! );
