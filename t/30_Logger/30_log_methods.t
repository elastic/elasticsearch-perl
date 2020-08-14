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
use Test::Exception;
use Search::Elasticsearch;

do './t/lib/LogCallback.pl' or die( $@ || $! );

isa_ok my $l = Search::Elasticsearch->new->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Logger';

test_level($_) for qw(debug info warning error critical trace);
test_throw($_) for qw(error critical);

done_testing;

#===================================
sub test_level {
#===================================
    my $level    = shift;
    my $levelf   = $level . 'f';
    my $is_level = 'is_' . $level;

    # ->debug
    ( $method, $format ) = ();
    ok $l->$level("foo"), "$level";
    is $method, $level, "$level - method";
    is $format, "foo", "$level - format";

    # ->debugf
    ( $method, $format ) = ();
    ok $l->$levelf( "foo %s", "bar" ), "$levelf";
    is $method, $level, "$levelf - method";
    is $format, "foo bar", "$levelf - format";

    # ->is_debug
    ( $method, $format ) = ();
    ok $l->$is_level(), "$is_level";
    is $method, $is_level, "$is_level - method";
    is $format, undef, "$is_level - format";
}

#===================================
sub test_throw {
#===================================
    my $level = shift;
    my $throw = 'throw_' . $level;
    my $re    = qr/\[Request\] \*\* Foo/;
    ( $method, $format ) = ();

    throws_ok { $l->$throw( 'Request', 'Foo', 42 ) } $re, $throw;

    is $@->{vars}, 42, "$throw - vars";
    is $method,   $level, "$throw - method";
    like $format, $re,    "$throw - format";

}
