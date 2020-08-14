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
use Test::Exception;
use Search::Elasticsearch;
use lib 't/lib';
use MockCxn qw(mock_static_client);

our $t;

# good request
$t = mock_static_client(
    { nodes => ['one'] },                         #
    { node  => 1, ping => 1 },                    #
    { node  => 1, code => '200', content => 1 }
);

ok $t->perform_request, 'Simple request';

# Request error
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '404', error => 'NotFound' }
);

throws_ok { $t->perform_request } qr/Missing/, 'Request error';

# Timeout error
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '509', error => 'Timeout' },
    { node => 1, ping => 1 },
    { node => 1, code => '200', content => 1 }
);

throws_ok { $t->perform_request } qr/Timeout/, 'Timeout error';
ok $t->perform_request, 'Timeout resolved';

# Cxn error
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '509', error => 'Cxn' },
    { node => 1, ping => 1 },
    { node => 1, code => '200', content => 1 }
);

ok $t->perform_request, 'Retried connection error';

# NoNodes from failure
$t = mock_static_client(
    { nodes => ['one'] },
    { node  => 1, ping => 1 },
    { node  => 1, code => '509', error => 'Cxn' },
    { node => 1, ping => 0 },
);

throws_ok { $t->perform_request } qr/NoNodes/, 'Cxn then bad ping';

# NoNodes reachable
$t = mock_static_client(
    { nodes => ['one'] },       #
    { node => 1, ping => 0 },
);

throws_ok { $t->perform_request } qr/NoNodes/, 'Initial bad ping';

done_testing;
