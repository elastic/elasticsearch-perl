package Search::Elasticsearch::Role::API;

use Moo::Role;
requires 'api_version';
requires 'api';

use Search::Elasticsearch::Util qw(throw);
use namespace::clean;

our %Handler = (
    string => sub {"$_[0]"},
    list   => sub {
        join ",", map { _to_bool($_) } ref $_[0] eq 'ARRAY'
            ? @{ shift() }
            : shift();
    },
    boolean => sub {
        $_[0] && !( $_[0] eq 'false' || $_[0] eq \0 ) ? 'true' : 'false';
    },
    enum => sub {
        join ",", map { _to_bool($_) } ref $_[0] eq 'ARRAY'
            ? @{ shift() }
            : shift();
    },
    number => sub { 0 + $_[0] },
    int    => sub { 0 + $_[0] },
    float  => sub { 0 + $_[0] },
    double => sub { 0 + $_[0] },
    time   => sub {"$_[0]"}
);

#===================================
sub _to_bool {
#===================================
    my $val = shift;
    return $val unless ref $val;
    return
          $val eq \0 ? 'false'
        : $val eq \1 ? 'true'
        : "$val"     ? 'true'
        :              'false';

}

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
