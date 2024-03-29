# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

use lib qw(lib t/lib);
use Search::Elasticsearch;
use Test::More;
use strict;
use warnings;

my $trace
    = !$ENV{TRACE}       ? undef
    : $ENV{TRACE} eq '1' ? 'Stderr'
    :                      [ 'File', $ENV{TRACE} ];

unless ($ENV{CLIENT_VER}) {
    plan skip_all => 'No $ENV{CLIENT_VER} specified';
    exit;
}
unless ($ENV{ES}) {
    plan skip_all => 'No Elasticsearch test node available';
    exit;
}

my $api      = "$ENV{CLIENT_VER}::Direct";
my $body     = $ENV{ES_BODY} || 'GET';
my $cxn      = $ENV{ES_CXN} || do "default_cxn.pl" || die( $@ || $! );
my $cxn_pool = $ENV{ES_CXN_POOL} || 'Static';
my $timeout  = $ENV{ES_TIMEOUT} || 30;
my @plugins  = split /,/, ( $ENV{ES_PLUGINS} || '' );
our %Auth;

my $es;

$ENV{ES} = $ENV{ELASTICSEARCH_URL} || 'https://elastic:changeme@localhost:9200';
$ENV{PERL_HTTP_TINY_SSL_INSECURE_BY_DEFAULT} = 1;

eval {
    $es = Search::Elasticsearch->new(
        nodes            => [ $ENV{ES} ],
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


unless ( $ENV{ES_SKIP_PING} ) {
    my $version = $es->info->{version}{number};
    my $api     = $es->api_version;
    unless ( $version eq '8.0.0-SNAPSHOT' || ( $api eq '0_90' && $version =~ /^0\.9/
        || substr( $api, 0, 1 ) eq substr( $version, 0, 1 ) ) )
    {
        plan skip_all =>
            "Tests are for API version $api but Elasticsearch is version $version\n";
        exit;
    }
}

return $es;
