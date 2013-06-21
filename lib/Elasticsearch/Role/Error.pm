package Elasticsearch::Role::Error;

use Moo::Role;
use Elasticsearch::Error();

#===================================
sub throw {
#===================================
    my ( $type, $msg, $vars ) = @_;
    die Elasticsearch::Error->new( $type, $msg, $vars, 1 );
}

#===================================
sub upgrade_error {
#===================================
    my $error = shift();
    return ref($error) && $error->isa('Elasticsearch::Error')
        ? $error
        : Elasticsearch::Error->new( "Internal", $error, {}, 1 );
}

1;

