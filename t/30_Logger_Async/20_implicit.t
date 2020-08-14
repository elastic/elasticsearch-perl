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
use Search::Elasticsearch::Async;

use Log::Any::Adapter;

Log::Any::Adapter->set( { category => 'elasticsearch.event' }, 'Stdout' );
Log::Any::Adapter->set( { category => 'elasticsearch.trace' }, 'Stderr' );

# default

isa_ok my $l = Search::Elasticsearch::Async->new->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Default Logger';

isa_ok $l->log_handle->adapter, 'Log::Any::Adapter::Stdout',
    'Default - Log to Stdout';
isa_ok $l->trace_handle->adapter, 'Log::Any::Adapter::Stderr',
    'Default - Trace to Stderr';

# override

isa_ok $l = Search::Elasticsearch::Async->new(
    log_to   => 'Stderr',
    trace_to => 'Stdout'
    )->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Override Logger';

isa_ok $l->log_handle->adapter, 'Log::Any::Adapter::Stderr',
    'Override - Log to Stderr';
isa_ok $l->trace_handle->adapter, 'Log::Any::Adapter::Stdout',
    'Override - Trace to Stdout';

done_testing;
