package Elasticsearch::Error;

our $DEBUG = 1;

@Elasticsearch::Error::Internal::ISA       = __PACKAGE__;
@Elasticsearch::Error::Param::ISA          = __PACKAGE__;
@Elasticsearch::Error::NoNodes::ISA        = __PACKAGE__;
@Elasticsearch::Error::ClusterBlocked::ISA = __PACKAGE__;
@Elasticsearch::Error::Request::ISA        = __PACKAGE__;
@Elasticsearch::Error::Timeout::ISA        = __PACKAGE__;
@Elasticsearch::Error::Connection::ISA     = __PACKAGE__;
@Elasticsearch::Error::Serializer::ISA     = __PACKAGE__;

@Elasticsearch::Error::Conflict::ISA
    = ( 'Elasticsearch::Error::Request', __PACKAGE__ );

@Elasticsearch::Error::Missing::ISA
    = ( 'Elasticsearch::Error::Request', __PACKAGE__ );

@Elasticsearch::Error::NotReady::ISA
    = ( 'Elasticsearch::Error::Connection', __PACKAGE__ );

use strict;
use warnings;
use overload (
    '""'  => '_stringify',
    'cmp' => '_compare',
);

use Data::Dumper();

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(throw upgrade_error);

#===================================
sub throw {
#===================================
    my ( $type, $msg, $vars ) = @_;
    die __PACKAGE__->new( $type, $msg, $vars, 1 );
}

#===================================
sub upgrade_error {
#===================================
    my $error = shift();
    return ref($error) && $error->isa('Elasticsearch::Error')
        ? $error
        : __PACKAGE__->new( "Internal", $error, {}, 1 );
}

#===================================
sub new {
#===================================
    my $class  = shift;
    my $type   = shift;
    my $msg    = shift;
    my $vars   = shift;
    my $caller = shift || 0;

    my $error_class = 'Elasticsearch::Error::' . $type;

    $msg = 'Unknown error' unless defined $msg;
    $msg =~ s/\n/\n    /g;

    my ( undef, $file, $line ) = caller($caller);
    my $self = bless {
        text => $msg,
        line => $line,
        file => $file,
        vars => $vars,
    }, $error_class;

    $self->{stacktrace} = $self->stacktrace( $caller + 1 )
        if $DEBUG;
    return $self;
}

#===================================
sub is {
#===================================
    my $self = shift;
    for (@_) {
        return 1 if $self->isa("Elasticsearch::Error::$_");
    }
    return 0;
}

#===================================
sub _stringify {
#===================================
    my $self = shift;
    local $Data::Dumper::Terse  = 1;
    local $Data::Dumper::Indent = 1;

    unless ( $self->{msg} ) {
        $self->{msg} = sprintf( "[ERROR] ** %s at %s line %d\n%s\n",
            ref $self, @{$self}{ 'file', 'line', 'text' } );

        if ( $self->{vars} ) {
            $self->{msg} .= sprintf( "With vars: %s\n",
                Data::Dumper::Dumper $self->{vars} );
        }

        if ( $self->{stacktrace} ) {
            $self->{msg}
                .= sprintf( "Stacktrace:\n%s\n", $self->{stacktrace} );
        }
    }
    return $self->{msg};

}

#===================================
sub _compare {
#===================================
    my ( $self, $other, $swap ) = @_;
    $self .= '';
    ( $self, $other ) = ( $other, $self ) if $swap;
    return $self cmp $other;
}

#===================================
sub stacktrace {
#===================================
    my $self = shift;
    my $caller = shift() || 1;

    my $o = sprintf "%s\n%-4s %-30s %-5s %s\n%s\n",
        '-' x 60, '#', 'Package', 'Line', 'Sub-routine', '-' x 60;

    my $i = 1;
    while ( my @caller = caller( ++$caller ) ) {
        next if $caller[0] eq 'Try::Tiny' and $caller[3] eq '(eval)';
        $o .= sprintf "%-4d %-30s %4d  %s\n", $i++, @caller[ 0, 2, 3 ];
    }
    return $o .= ( '-' x 60 ) . "\n";
}

=head1 NAME

Elasticsearch::Error - Exception objects for Elasticsearch

=head1 DESCRIPTION

Elasticsearch::Error is a base class for exceptions thrown by any Elasticsearch
code.

There are several exception subclasses, which indicate different types of error.
All of them inherit from L<Elasticsearch::Error>, and all include:

    $error->{-text}         # error message
    $error->{-file}         # file where error was thrown
    $error->{-line}         # line where error was thrown

They may also include:

    $error->{-vars}         # Any relevant variables related to the error
    $error->{-stacktrace}   # A stacktrace, if $Elasticsearch::DEBUG == 1

Error objects can be stringified, and include all of the above information
in the string output.

=head1 EXCEPTION CLASSES

=over

=item * Elasticsearch::Error::Param

An incorrect parameter was passed in

=item * Elasticsearch::Error::Timeout

The request timed out

=item * Elasticsearch::Error::Connection

There was an error connecting to the current node. The request will be
retried on another node.

=item * Elasticsearch::Error::NotReady

The current node is not yet able to serve requests. The request will be
retried on another node. C<Elasticsearch::Error::NotReady> inherits from
C<Elasticsearch::Error::Connection>.

=item * Elasticsearch::Error::ClusterBlocked

The cluster was unable to process the request because it is currently blocking,
eg the requested index is closed.

=item * Elasticsearch::Error::Request

There was some other error performing the request

=item * Elasticsearch::Error::Conflict

There was a versioning conflict while performing an index/create/delete
operation.  C<Elasticsearch::Error::Conflict> inherits from
C<Elasticsearch::Error::Request>.

The lastest version number is available as:

    $error->{-vars}{current_version};

=item * Elasticsearch::Error::Missing

Tried to get/delete a document or index that doesn't exist.
C<Elasticsearch::Error::Missing> inherits from
C<Elasticsearch::Error::Request>.

=item * Elasticsearch::Error::NoServers

No servers are available

=item * Elasticsearch::Error::JSON

There was an error parsing a JSON doc

=item * Elasticsearch::Error::Internal

An internal error - you shouldn't see these

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2010 - 2011 Clinton Gormley.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;

