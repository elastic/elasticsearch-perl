# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use lib 't/lib';

$ENV{ES_VERSION} = '6_0';
$ENV{ES_CXN} = 'NetCurl';
use Net::Curl::Easy qw(
    CURLOPT_CAINFO
);

our $Throws_SSL = "SSL";

sub ssl_options {
    return { CURLOPT_CAINFO() => $_[0] };
}

do "es_sync_auth.pl" or die( $@ || $! );
