package Search::Elasticsearch::Async;

use Search::Elasticsearch 1.10;

use Promises 0.91 ();
use Moo 1.003;
extends 'Search::Elasticsearch';
use Search::Elasticsearch::Util qw(parse_params);
use namespace::clean;

our $VERSION = '1.10';

#===================================
sub new {
#===================================
    my ( $class, $params ) = parse_params(@_);
    $class->SUPER::new(
        {   cxn_pool            => 'Async::Static',
            transport           => 'Async',
            cxn                 => 'AEHTTP',
            bulk_helper_class   => 'Async::Bulk',
            scroll_helper_class => 'Async::Scroll',
            %$params
        }
    );
}

1;

# ABSTRACT: Async interface to Elasticsearch using Promises

__END__
