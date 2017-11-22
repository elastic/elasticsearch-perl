package Search::Elasticsearch::CxnAuth::Basic;

use Moo;
#with 'Search::Elasticsearch::Role::Cxn', 'Search::Elasticsearch::Role::Is_Sync';

use namespace::clean;

sub authenticate_request {
    my ($self, $uri, $params ) = @_;

    # do the authentication there
    #print "Going there\n\n";

    return;
 }

1;
