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
use Test::Deep;
use strict;
use warnings;
use lib 't/lib';

$ENV{ES_VERSION} = '0_90';
my $es = do "es_sync.pl" or die( $@ || $! );

$es->indices->delete( index => '_all' );

test_flush(
    "max count",    #
    { max_count => 3 },    #
    1, 2, 0, 1, 2, 0, 1, 2, 0, 1
);

test_flush(
    "max size",            #
    { max_size => 95 },    #
    1, 2, 3, 0, 1, 2, 3, 0, 1, 2
);

test_flush(
    "max size > max_count",
    { max_size => 95, max_count => 3 },
    1, 2, 0, 1, 2, 0, 1, 2, 0, 1
);

test_flush(
    "max size < max_count",
    { max_size => 95, max_count => 5 },
    1, 2, 3, 0, 1, 2, 3, 0, 1, 2
);

test_flush(
    "max size = 0, max_count",
    { max_size => 0, max_count => 5 },
    1, 2, 3, 4, 0, 1, 2, 3, 4, 0
);

test_flush(
    "max count = 0, max_size",
    { max_size => 95, max_count => 0 },
    1, 2, 3, 0, 1, 2, 3, 0, 1, 2
);

test_flush(
    "max count = 0, max_size = 0",
    { max_size => 0, max_count => 0 },
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10
);

test_flush(
    "max_count = 5, max_time = 5",
    { max_count => 5, max_time => 5 },
    1, 2, 0, 1, 2, 3, 4, 0, 0, 1
);

done_testing;

$es->indices->delete( index => 'test' );

#===================================
sub test_flush {
#===================================
    my $title  = shift;
    my $params = shift;
    my $b      = $es->bulk_helper(
        %$params,
        index => 'test',
        type  => 'test'
    );

    my @seq = @_;

    $es->indices->delete( index => 'test', ignore => 404 );
    $es->indices->create( index => 'test' );
    $es->cluster->health( wait_for_status => 'yellow' );

    for my $i ( 10 .. 19 ) {

        # sleep on 12 or 18 if max_time specified
        if ( $params->{max_time} && ( $i == 12 || $i == 18 ) ) {
            $b->_last_flush( time - $params->{max_time} - 1 );
        }
        $b->index( { id => $i, source => {} } );
        is $b->_buffer_count, shift @seq, "$title - " . ( $i - 9 );
    }
    $b->flush;
    is $b->_buffer_count, 0, "$title - final flush";
    $es->indices->refresh;
    is $es->count->{count}, 10, "$title - all docs indexed";

}
