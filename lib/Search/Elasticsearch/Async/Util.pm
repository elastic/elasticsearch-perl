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
