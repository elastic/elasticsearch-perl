use Test::More;
use Test::Deep;
use File::Basename qw(basename);

plan tests => 1;
my @perl = sort
    grep {/^[a-z]/}
    map { basename( $_, '.t' ) } glob('t/90_Client_Spec/*.t');

my @spec = sort
    grep {/^[a-z]/}
    map  { basename($_) }
    grep { -d $_ } glob('spec/test/*');

cmp_deeply( \@perl, \@spec, 'Testing full spec' ) and exit;

my %bag = map { $_ => 1 } @spec;
delete $bag{$_} for @perl;

diag "Missing tests for:";
diag " * $_" for sort keys %bag;
