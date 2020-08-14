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

use Test::More;
use strict;
use warnings;
use AE;
use lib 't/lib';

$ENV{ES_VERSION} = '6_0';
my $es = do "es_async.pl" or die( $@ || $! );

wait_for( $es->indices->delete( index => '_all' ) );

my $error;

wait_for(
    $es->index( index => 'test', type => 'test', id => 1, body => {} )->then(
        sub {
            $es->index(
                index   => 'test',
                type    => 'test',
                id      => 1,
                body    => {},
                version => 2
            );
        }
    )->catch( sub { $error = shift() } )
);

ok $error->is('Conflict'), 'Conflict Exception';
is $error->{vars}{current_version}, 1, "Error has current version v1";

done_testing;
