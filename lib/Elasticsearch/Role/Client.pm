package Elasticsearch::Role::Client;

use Moo::Role;
with 'Elasticsearch::Role::Error';
use namespace::autoclean;

use Elasticsearch::Util::API::Path qw(path_handler);
use Elasticsearch::Util::API::QS qw(qs_handler);
use Try::Tiny;

has 'transport' => ( is => 'ro', required => 1 );
has 'logger'    => ( is => 'ro', required => 1 );

#===================================
sub perform_request {
#===================================
    my $self    = shift;
    my $request = $self->parse_request(@_);
    return $self->transport->perform_request($request);
}

#===================================
sub parse_request {
#===================================
    my $self   = shift;
    my $name   = shift;
    my $defn   = shift;
    my $params = { ref $_[0] ? %{ shift() } : @_ };

    my $request;
    try {
        $request = {
            method => $defn->{method} || 'GET',
            path => $self->parse_path( $defn->{path}, $params ),
            body => $self->parse_body( $defn->{body}, $params ),
            qs   => $self->parse_qs( $defn->{qs},     $params ),
        };
        $request->{ignore_missing} = delete $request->{qs}{ignore_missing}
            if $request->{qs}{ignore_missing};
    }
    catch {
        chomp $_;
        $self->logger->throw_error( 'Param',
                  "$_ in ($name) request. "
                . "See http://elasticsearch.org"
                . $defn->{doc} );
    };
    return $request;
}

#===================================
sub parse_path {
#===================================
    my ( $self, $defn, $params ) = @_;
    return delete $params->{path}
        if $params->{path};
    path_handler( $defn, $params );
}

#===================================
sub parse_body {
#===================================
    my ( $self, $defn, $params ) = @_;
    if ( defined $defn ) {
        die("Missing required param (body)\n")
            if $defn->{required} && !$params->{body};
        return delete $params->{body};
    }
    die("Unknown param (body)\n") if $params->{body};
    return undef;
}

#===================================
sub parse_qs {
#===================================
    my ( $self, $defn, $params ) = @_;
    my %qs;

    if ( my $raw = delete $params->{params} ) {
        die("Arg (params) shoud be a hashref\n")
            unless ref $raw eq 'HASH';
        %qs = %$raw;
    }

    for my $key ( keys %$params ) {
        my $key_defn = $defn->{$key}
            or die("Unknown param ($key)\n");
        my $handler = qs_handler( $key_defn->{type} );
        $qs{$key} = $handler->( delete $params->{$key} );
    }
    return \%qs;
}

1;
