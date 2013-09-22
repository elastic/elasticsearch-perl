package Elasticsearch::Error;

use Moo;

our $DEBUG = 0;

@Elasticsearch::Error::Internal::ISA       = __PACKAGE__;
@Elasticsearch::Error::Param::ISA          = __PACKAGE__;
@Elasticsearch::Error::NoNodes::ISA        = __PACKAGE__;
@Elasticsearch::Error::ClusterBlocked::ISA = __PACKAGE__;
@Elasticsearch::Error::Request::ISA        = __PACKAGE__;
@Elasticsearch::Error::Timeout::ISA        = __PACKAGE__;
@Elasticsearch::Error::Cxn::ISA            = __PACKAGE__;
@Elasticsearch::Error::Serializer::ISA     = __PACKAGE__;

@Elasticsearch::Error::Conflict::ISA
    = ( 'Elasticsearch::Error::Request', __PACKAGE__ );

@Elasticsearch::Error::Missing::ISA
    = ( 'Elasticsearch::Error::Request', __PACKAGE__ );

@Elasticsearch::Error::ContentLength::ISA
    = ( __PACKAGE__, 'Elasticsearch::Error::Request' );

@Elasticsearch::Error::Unavailable::ISA
    = ( 'Elasticsearch::Error::Cxn', __PACKAGE__ );

use overload (
    '""'  => '_stringify',
    'cmp' => '_compare',
);

use Data::Dumper();

#===================================
sub new {
#===================================
    my ( $class, $type, $msg, $vars, $caller ) = @_;
    return $type if ref $type;
    $caller ||= 0;

    my $error_class = 'Elasticsearch::Error::' . $type;
    $msg = 'Unknown error' unless defined $msg;

    local $DEBUG = 2 if $type eq 'Internal';

    my $stack = $class->_stack;

    my $self = bless {
        type  => $type,
        text  => $msg,
        vars  => $vars,
        stack => $stack,
    }, $error_class;

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
    local $Data::Dumper::Indent = !!$DEBUG;

    unless ( $self->{msg} ) {
        my $stack  = $self->{stack};
        my $caller = $stack->[0];
        $self->{msg}
            = sprintf( "[%s] ** %s, called from sub %s at %s line %d.",
            $self->{type}, $self->{text}, @{$caller}[ 3, 1, 2 ] );

        if ( $self->{vars} ) {
            $self->{msg} .= sprintf( " With vars: %s\n",
                Data::Dumper::Dumper $self->{vars} );
        }

        if ( @$stack > 1 ) {
            $self->{msg}
                .= sprintf( "Stacktrace:\n%s\n", $self->stacktrace($stack) );
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
sub _stack {
#===================================
    my $self = shift;
    my $caller = shift() || 2;

    my @stack;
    while ( my @caller = caller( ++$caller ) ) {
        if ( $caller[0] eq 'Try::Tiny' or $caller[0] eq 'main' ) {
            next if $caller[3] eq '(eval)';
            if ( $caller[3] =~ /^(.+)::__ANON__\[(.+):(\d+)\]$/ ) {
                @caller = ( $1, $2, $3, '(ANON)' );
            }
        }
        next
            if $caller[0] =~ /^Elasticsearch/
            and $DEBUG < 2 || $caller[3] eq 'Try::Tiny::try';
        push @stack, [ @caller[ 0, 1, 2, 3 ] ];
        last unless $DEBUG > 1;
    }
    return \@stack;
}

#===================================
sub stacktrace {
#===================================
    my $self = shift;
    my $stack = shift || $self->_stack();

    my $o = sprintf "%s\n%-4s %-40s %-5s %s\n%s\n",
        '-' x 60, '#', 'Package', 'Line', 'Sub-routine', '-' x 60;

    my $i = 1;
    for (@$stack) {
        $o .= sprintf "%-4d %-40s %4d  %s\n", $i++, @{$_}[ 0, 2, 3 ];
    }

    return $o .= ( '-' x 60 ) . "\n";
}
1;

# ABSTRACT: Errors thrown by Elasticsearch

=head1 DESCRIPTION

Errors thrown by Elasticsearch are error objects, which can include
a strack trace and information to help debug problems. An error object
consists of the following:

    {
        type  => $type,              # eg Missing
        text  => 'Error message',
        vars  => {...},              # vars which may help to explain the error
        stack => [...],              # a stack trace
    }

The C<$Elasticsearch::Error::DEBUG> variable can be set to C<1> or C<2>
to increase the verbosity of errors.

=head1 ERROR CLASSES

The following error classes are defined:

=over

=item * C<Elasticsearch::Error::Param>

A bad parameter has been passed to a method.

=item * C<Elasticsearch::Error::Request>

There was some generic error performing your request in Elasticsearch.
This error is triggered by HTTP status codes C<400> and C<500>. This class
has the following sub-classes:

=over

=item * C<Elasticsearch::Error::Missing>

A resource that you requested was not found.  These errors are triggered
by the C<404> HTTP status code.

=item * C<Elastisearch::Error::Conflict>

Your request could not be performed because of some conflict.  For instance,
if you try to delete a document with a particular version number, and the
document has already changed, it will throw a C<Conflict> error.  If it can,
it will include the C<current_version> in the error vars. This error
is triggered by the C<409> HTTP status code.

=item * C<Elasticsearch::Error::Unavailable>

The service you requested is temporarily unavailable. This error
is triggered by the C<503> HTTP status code.

=item * C<Elasticsearch::Error::ContentLength>

The request body was longer than the
L<max_content_length|Elasticsearch::Role::Cxn::HTTP/max_content_length>.

=back

=item * C<Elasticsearch::Error::Timeout>

The request timed out.

=item * C<Elasticsearch::Error::Cxn>

There was an error connecting to a node in the cluster.  This error
indicates node failure and will be retried on another node.
This error has the following sub-class:

=over

=item * C<Elasticsearch::Error::Unavailable>

The current node is unable to handle your request at the moment. Your
request will be retried on another node.  This error is triggered by
the C<503> HTTP status code.

=back

=item * C<Elasticsearch::Error::ClusterBlocked>

The cluster was unable to process the request because it is currently blocking,
eg there are not enough master nodes to form a cluster. This error is
triggered by the C<403> HTTP status code.

=item * C<Elasticsearch::Error::Serializer>

There was an error serializing a variable or deserializing a string.

=item * C<Elasticsarch::Error::Internal>

An internal error occurred - please report this as a bug in
this module.

=back
