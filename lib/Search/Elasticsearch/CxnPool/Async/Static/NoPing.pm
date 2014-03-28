package Search::Elasticsearch::CxnPool::Async::Static::NoPing;

use Moo;
with 'Search::Elasticsearch::Role::CxnPool::Static::NoPing',
    'Search::Elasticsearch::Role::Is_Async';

use Promises qw(deferred);
use Try::Tiny;
use namespace::clean;

#===================================
around 'next_cxn' => sub {
#===================================
    my ( $orig, $self ) = @_;

    my $deferred = deferred;
    try {
        my $cxn = $orig->($self);
        $deferred->resolve($cxn);
    }
    catch {
        $deferred->reject($_);
    };

    $deferred->promise;

};

1;
__END__
