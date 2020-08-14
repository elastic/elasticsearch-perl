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

( $method, $format ) = ();
ok $l->deprecation( "foo", { foo => 1 } ), "deprecation";
is $method, "warning", "deprecation - method";
is $format, "[DEPRECATION] foo - In request: {foo => 1}", "deprecation - format";

done_testing;
