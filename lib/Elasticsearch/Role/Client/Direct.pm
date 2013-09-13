package Elasticsearch::Role::Client::Direct;

use Moo::Role;
with 'Elasticsearch::Role::Client';
use namespace::autoclean;

use Elasticsearch::Util::API::Path qw(path_handler);
use Elasticsearch::Util::API::QS qw(qs_handler);
use Try::Tiny;

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
            ignore    => delete $params->{ignore} || [],
            method    => $defn->{method}          || 'GET',
            serialize => $defn->{serialize}       || 'std',
            path => $self->_parse_path( $defn->{path}, $params ),
            body => $self->_parse_body( $defn->{body}, $params ),
            qs   => $self->_parse_qs( $defn->{qs},     $params ),
        };
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
sub _parse_path {
#===================================
    my ( $self, $defn, $params ) = @_;
    return delete $params->{path}
        if $params->{path};
    path_handler( $defn, $params );
}

#===================================
sub _parse_body {
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
sub _parse_qs {
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

#===================================
sub _install_actions {
#===================================
    my ( $class, $group ) = @_;
    my $defns = $class->api;
    my $stash = Package::Stash->new($class);

    my $group_qr = $group ? qr/$group\./ : qr//;
    for my $action ( keys %$defns ) {
        my ($name) = ( $action =~ /^$group_qr([^.]+)$/ )
            or next;
        next if $stash->has_symbol( '&' . $name );

        my $defn = $defns->{$action};
        $stash->add_symbol(
            '&' . $name => sub {
                shift->perform_request( $action, $defn, @_ );
            }
        );
    }
}

1;
