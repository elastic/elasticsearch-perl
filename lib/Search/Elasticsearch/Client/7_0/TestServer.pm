package Search::Elasticsearch::Client::7_0::TestServer;

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
