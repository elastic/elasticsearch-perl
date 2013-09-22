package Elasticsearch::Role::Client::Direct;

use Moo::Role;
with 'Elasticsearch::Role::Client';
use namespace::autoclean;
use Try::Tiny;

#===================================
sub parse_request {
#===================================
    my $self   = shift;
    my $defn   = shift || {};
    my $params = { ref $_[0] ? %{ shift() } : @_ };

    my $request;
    try {
        $request = {
            ignore    => delete $params->{ignore} || [],
            method    => $defn->{method}          || 'GET',
            serialize => $defn->{serialize}       || 'std',
            path => $self->_parse_path( $defn->{path_handler}, $params ),
            body => $self->_parse_body( $defn->{body},         $params ),
            qs   => $self->_parse_qs( $defn->{qs_handlers},    $params ),
        };
    }
    catch {
        chomp $_;
        my $name = $defn->{name}||'<unknown method>';
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
    my ( $self, $handler, $params ) = @_;
    die "No (path_handler) defined\n" unless $handler;
    return delete $params->{path}
        if $params->{path};
    $handler->($params);
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
    my ( $self, $handlers, $params ) = @_;
    die "No (qs_handlers) defined\n" unless $handlers;
    my %qs;

    if ( my $raw = delete $params->{params} ) {
        die("Arg (params) shoud be a hashref\n")
            unless ref $raw eq 'HASH';
        %qs = %$raw;
    }

    for my $key ( keys %$params ) {
        my $key_defn = $handlers->{$key}
            or die("Unknown param ($key)\n");
        my $handler = $key_defn->{handler}
            or die "No (handler) defined for ($key)\n";
        $qs{$key} = $handler->( delete $params->{$key} );
    }
    return \%qs;
}

#===================================
sub _install_api {
#===================================
    my ( $class, $group ) = @_;
    my $defns = $class->api;
    my $stash = Package::Stash->new($class);

    my $group_qr = $group ? qr/$group\./ : qr//;
    for my $action ( keys %$defns ) {
        my ($name) = ( $action =~ /^$group_qr([^.]+)$/ )
            or next;
        next if $stash->has_symbol( '&' . $name );

        my %defn = ( name => $name, %{ $defns->{$action} } );
        $stash->add_symbol(
            '&' . $name => sub {
                shift->perform_request( \%defn, @_ );
            }
        );
    }
}

1;
