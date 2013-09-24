use Elasticsearch;
use Test::More;
use strict;
use warnings;

my $trace
    = !$ENV{TRACE}       ? undef
    : $ENV{TRACE} eq '1' ? 'Stderr'
    :                      [ 'File', $ENV{TRACE} ];

my $es;
if ( $ENV{ES} ) {
    $es = Elasticsearch->new(
        nodes    => $ENV{ES},
        trace_to => $trace
    );
    eval { $es->ping; } or do {
        diag $@;
        undef $es;
    };
}
unless ($es) {
    plan skip_all => 'No Elasticsearch test node available';
    exit;
}

return $es;
