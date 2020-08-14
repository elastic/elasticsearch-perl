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
use Search::Elasticsearch;
use File::Temp;
my $file = File::Temp->new( EXLOCK => 0 );

# default

isa_ok my $l = Search::Elasticsearch->new->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Default Logger';

is $l->log_as,   'elasticsearch.event', 'Log as';
is $l->trace_as, 'elasticsearch.trace', 'Trace as';
isa_ok $l->log_handle->adapter, 'Log::Any::Adapter::Null',
    'Default - Log to NULL';
isa_ok $l->trace_handle->adapter, 'Log::Any::Adapter::Null',
    'Default - Trace to NULL';

# stdout/stderr

isa_ok $l
    = Search::Elasticsearch->new( log_to => 'Stderr', trace_to => 'Stdout' )
    ->logger,
    'Search::Elasticsearch::Logger::LogAny',
    'Std Logger';

isa_ok $l->log_handle->adapter, 'Log::Any::Adapter::Stderr',
    'Std - Log to Stderr';
isa_ok $l->trace_handle->adapter, 'Log::Any::Adapter::Stdout',
    'Std - Trace to Stdout';

# file

isa_ok $l = Search::Elasticsearch->new(
    log_to   => [ 'File', $file->filename ],
    trace_to => [ 'File', $file->filename ]
    )->logger, 'Search::Elasticsearch::Logger::LogAny',
    'File Logger';

isa_ok $l->log_handle->adapter, 'Log::Any::Adapter::File',
    'File - Log to file';
isa_ok $l->trace_handle->adapter, 'Log::Any::Adapter::File',
    'File - Trace to file';

done_testing;
