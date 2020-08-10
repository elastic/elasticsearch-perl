# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use IO::Socket::SSL;
use lib 't/lib';

$ENV{ES_VERSION} = '7_0';
$ENV{ES_CXN} = 'HTTPTiny';
our $Throws_SSL = "SSL";

sub ssl_options {
    return {
        SSL_verify_mode => SSL_VERIFY_PEER,
        SSL_ca_file     => $_[0]
    };
}

do "es_sync_auth.pl" or die( $@ || $! );
