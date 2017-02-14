package Search::Elasticsearch::Role::API;

use Moo::Role;
requires 'api_version';
requires 'api';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

our %Handler = (
    string => sub {"$_[0]"},
    list   => sub {
        ref $_[0] eq 'ARRAY'
            ? join( ',', @{ shift() } )
            : shift();
    },
    boolean => sub {
        $_[0] && !( $_[0] eq 'false' || $_[0] eq \0 ) ? 'true' : 'false';
    },
    enum => sub {
        ref $_[0] eq 'ARRAY'
            ? join( ',', @{ shift() } )
            : shift();
    },
    number => sub { 0 + $_[0] },
    time   => sub {"$_[0]"}
);

#===================================
sub _qs_init {
#===================================
    my $class = shift;
    my $API   = shift;
    for my $spec ( keys %$API ) {
        my $qs = $API->{$spec}{qs};
        for my $param ( keys %$qs ) {
            my $handler = $Handler{ $qs->{$param} }
                or throw( "Internal",
                      "Unknown type <"
                    . $qs->{$param}
                    . "> for param <$param> in API <$spec>" );
            $qs->{$param} = $handler;
        }
    }
}

1;

# ABSTRACT: Provides common functionality for API implementations
