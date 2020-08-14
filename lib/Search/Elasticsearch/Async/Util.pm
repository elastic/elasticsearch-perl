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

package Search::Elasticsearch::Async::Util;

use Moo;
use Scalar::Util qw(blessed);
use Sub::Exporter -setup => { exports => ['thenable'] };

#===================================
sub thenable {
#===================================
    return
           unless @_ == 1
        && blessed $_[0]
        && $_[0]->can('then');
    return shift();
}
1;

# ABSTRACT: A utility class for internal use by Elasticsearch
