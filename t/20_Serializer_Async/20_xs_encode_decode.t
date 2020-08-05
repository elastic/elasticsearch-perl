# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;

eval { require JSON::XS; 1 } or do {
    plan skip_all => 'JSON::XS not installed';
    done_testing;
};

our $JSON_BACKEND = 'JSON::XS';
do './t/20_Serializer_Async/encode_pretty.pl' or die( $@ || $! );

