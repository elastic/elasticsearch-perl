use lib 't/lib';

use Cwd();
use Data::Dump qw(pp); print STDERR ((pp scalar \@INC, Cwd::cwd()),"\n");

$ENV{ES_CXN} = 'HTTPTiny';
do "es_sync_fork.pl" or die $!;

