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

package Search::Elasticsearch::Client::6_0::TestServer;

use strict;
use warnings;

#===================================
sub command_line {
#===================================
    my ( $class, $ts, $pid_file, $dir, $transport, $http ) = @_;

    return (
        $ts->es_home . '/bin/elasticsearch',
        '-p',
        $pid_file->filename,
        map {"-E$_"} (
            'path.data=' . $dir,
            'network.host=127.0.0.1',
            'cluster.name=es_test',
            'discovery.zen.ping_timeout=1s',
            'discovery.zen.ping.unicast.hosts=127.0.0.1:' . $ts->es_port,
            'transport.tcp.port=' . $transport,
            'http.port=' . $http,
            @{ $ts->conf }
        )
    );
}

1

# ABSTRACT: Client-specific backend for Search::Elasticsearch::TestServer
