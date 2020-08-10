# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use lib 't/lib';

$ENV{ES_VERSION} = '7_0';
$ENV{ES_CXN} = 'AEHTTP';

sub ssl_options {
    return {
        verify          => 1,
        verify_peername => 'https',
        ca_file         => $_[0]
    };
}

do "es_async_auth.pl" or die( $@ || $! );
