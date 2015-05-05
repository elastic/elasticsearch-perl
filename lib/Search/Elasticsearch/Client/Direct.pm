package Search::Elasticsearch::Client::Direct;

use parent 'Search::Elasticsearch::Client::1_0::Direct';

warn <<'END';
The Search::Elasticsearch::Client::Direct class is deprecated.
Please specify the version of the API that you would like to use, eg:

     $e = Search::Elasticsearch->new(
         client => '1_0::Direct'        # default
     );

END

1;

__END__

# ABSTRACT: Deprecated


=head1 DESCRIPTION

This class has been deprecated.  Please see the
L<Search::Elasticsearch::Client::1_0::Direct> class instead.
