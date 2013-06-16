package Elasticsearch::Role::Error;

use Moo::Role;

#===================================
sub throw {
#===================================
    my ( $type, $msg, $vars ) = @_;
    die Elastisearch::Error->new( $type, $msg, $vars, 1 );
}

#===================================
sub upgrade_error {
#===================================
    my $error = shift();
    return ref($error) && $error->isa('Elasticsearch::Error')
        ? $error
        : Elastisearch::Error->new( "Internal", $error, {}, 1 );
}

1;

