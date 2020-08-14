#!/usr/bin/env perl

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

use lib 'lib';
use Search::Elasticsearch;
use Capture::Tiny qw(capture_merged tee_merged);

my $es = Search::Elasticsearch->new;
my $base_url
    = "https://download.elastic.co/elasticsearch/elasticsearch";

my @startup_opts = qw(
    -Des.network.host=localhost
    -Des.discovery.zen.ping.multicast.enabled=false
    -Des.discovery.zen.ping_timeout=1
    -Des.node.bench=true
    -Des.script.disable_dynamic=false
);

sub run(@);

if ( my $version = $ENV{ES_VERSION} ) {
    eval { run qw(killall java) };

    mkdir('servers');
    chdir 'servers' or die $!;
    my $es_dir = "elasticsearch-${version}";

    # Download ES version
    unless ( -d $es_dir ) {
        print "Downloading Elasticsearch v$version\n";
        run 'curl', '-O', "$base_url/$es_dir.zip";
        run 'unzip', "$es_dir.zip";
    }

    # Start ES
    print "Starting Elasticsearch v$version\n";
    if ( $version =~ /^0/ ) {
        run "$es_dir/bin/elasticsearch", @startup_opts;
    }
    else {
        run "$es_dir/bin/elasticsearch", "-d", @startup_opts;
    }
    chdir "..";

    # Wait for it to start
    local $| = 1;
    for ( 1 .. 20 ) {
        eval { $es->ping } and last;
        print ".";
        sleep 1;
    }
    print "\n";
}
else {
    print "No ES_VERSION provided. Using running instance\n";
}

chdir 'elasticsearch' or die $!;
run qw(git fetch);

print "Retrieving Elasticsearch version\n";

my $info    = $es->info;
my $version = $info->{version}{number};

# For 0.90.* versions, use the most recent commit of 0.90
if ( $version =~ /^0.90/ ) {
    print "Checking out 0.90\n";
    run qw(git checkout -B 0.90 origin/0.90);
    exit;
}

# Check out the build hash
my $hash = $info->{version}{build_hash};
unless ( length($hash) == 40 ) {
    print "Unknown build hash: $hash\n";
    print "Using latest master";
    run qw(git checkout -B master origin/master);
    exit;
}

print "Checkout out commit: $hash\n";
run qw(git checkout -B temp ), $hash;
exit;

#===================================
sub run (@) {
#===================================
    my @args = @_;
    my ( $out, $ok ) = capture_merged { system(@args) == 0 };

    die "Error executing: @args\n$out"
        unless $ok;

    return $out;
}

