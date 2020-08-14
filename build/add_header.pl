#!/usr/bin/env perl

use strict;
use warnings;
use File::Find;
use File::Basename;
use File::Slurp;
use Cwd qw(abs_path);
use v5.12;

my $root = dirname(abs_path(__FILE__ . '/..'));

my @dir_to_search = (
    $root . '/lib',
    $root . '/t',
    $root . '/test',
    $root . '/build',
    $root . '/travis'
);

my $header = <<EOL;
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
EOL

my $shebang = '#!/usr/bin/env perl';

my @suffix = ('.pm', '.pl', '.t');
my %hash = map {$_ => 1} @suffix;

say "SEARCH for PERL files...";
find(\&add_header, @dir_to_search);
say "END";

sub add_header { 
    my ($filename, $dirs, $suffix) = fileparse($File::Find::name, @suffix);

    return if !$hash{$suffix};
    
    my $file_content = read_file($File::Find::name);
    if (index($file_content, $header) == -1) {
        printf("\tAdding header to %s\n", $File::Find::name);
        if (index($file_content, $shebang) == -1) {
            $file_content = $header . "\n" . $file_content;
        } else {
            $file_content =~ s/$shebang/$shebang\n\n$header/;
        }
        write_file($File::Find::name, $file_content);
    }
}