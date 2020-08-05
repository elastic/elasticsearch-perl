# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

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
