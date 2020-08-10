# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Log::Any::Adapter::Callback 0.09;
use Log::Any::Adapter;

our ( $method, $format );
Log::Any::Adapter->set(
    'Callback',
    min_level  => 'trace',
    logging_cb => sub {
        ( $method, undef, $format ) = @_;
    },
    detection_cb => sub {
        $method = shift;
    }
);

1
