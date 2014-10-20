package Search::Elasticsearch::Error;

use Moo;

our $DEBUG = 0;

@Search::Elasticsearch::Error::Internal::ISA       = __PACKAGE__;
@Search::Elasticsearch::Error::Param::ISA          = __PACKAGE__;
@Search::Elasticsearch::Error::NoNodes::ISA        = __PACKAGE__;
@Search::Elasticsearch::Error::ClusterBlocked::ISA = __PACKAGE__;
@Search::Elasticsearch::Error::Request::ISA        = __PACKAGE__;
@Search::Elasticsearch::Error::Timeout::ISA        = __PACKAGE__;
@Search::Elasticsearch::Error::Cxn::ISA            = __PACKAGE__;
@Search::Elasticsearch::Error::Serializer::ISA     = __PACKAGE__;

@Search::Elasticsearch::Error::Conflict::ISA
    = ( 'Search::Elasticsearch::Error::Request', __PACKAGE__ );

@Search::Elasticsearch::Error::Missing::ISA
    = ( 'Search::Elasticsearch::Error::Request', __PACKAGE__ );

@Search::Elasticsearch::Error::ContentLength::ISA
    = ( __PACKAGE__, 'Search::Elasticsearch::Error::Request' );

@Search::Elasticsearch::Error::Unavailable::ISA
    = ( 'Search::Elasticsearch::Error::Cxn', __PACKAGE__ );

use overload (
    '""'  => '_stringify',
    'cmp' => '_compare',
);

use Data::Dumper();
our $StackTracePackage = "Devel::StackTrace";
our $StackTraceOptions = [];

#===================================
sub new {
#===================================
    my ( $class, $type, $msg, $vars, $caller ) = @_;
    return $type if ref $type;
    $caller ||= 0;

    my $error_class = 'Search::Elasticsearch::Error::' . $type;
    $msg = 'Unknown error' unless defined $msg;

    local $DEBUG = 2 if $type eq 'Internal';

    my $self = bless {
        type  => $type,
        text  => $msg,
        vars  => $vars,
    }, $error_class;

    if (our $StackTrace) {
        require $StackTracePackage;
        $self->{stack} = $StackTracePackage->new(@$StackTraceOptions);
    }

    return $self;
}


#===================================
sub is {
#===================================
    my $self = shift;
    for (@_) {
        return 1 if $self->isa("Search::Elasticsearch::Error::$_");
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
        $self->{msg} = sprintf( "[%s] ** %s", $self->{type}, $self->{text});

        if ( $self->{vars} ) {
            $self->{msg} .= sprintf( " With vars: %s\n",
                Data::Dumper::Dumper $self->{vars} );
        }

        if ( $self->{stack} ) {
            $self->{msg} .= sprintf( "Stacktrace:\n%s\n", $self->{stack}->as_string() );
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

1;

# ABSTRACT: Errors thrown by Search::Elasticsearch

=head1 DESCRIPTION

Errors thrown by Search::Elasticsearch are error objects, which can include
a stack trace and information to help debug problems. An error object
consists of the following:

    {
        type  => $type,              # eg Missing
        text  => 'Error message',
        vars  => {...},              # vars which may help to explain the error
        stack => [...],              # a Devel::StackTrace if $ElasticSearch::Error::StackTrace is true
                                     # customize the trace type with $ElasticSearch::Error::StackTracePackage e.g.
                                     # "Devel::StackTrace::WithLexicals"
                                     # trace parameters are set via $ElasticSearch::Error::StackTraceOptions as 
                                     # an array ref that is de-refed and passed to the call to new of the 
                                     # stack trace package.
    }

The C<$Search::Elasticsearch::Error::DEBUG> variable can be set to C<1> or C<2>
to increase the verbosity of errors.

=head1 ERROR CLASSES

The following error classes are defined:

=over

=item * C<Search::Elasticsearch::Error::Param>

A bad parameter has been passed to a method.

=item * C<Search::Elasticsearch::Error::Request>

There was some generic error performing your request in Elasticsearch.
This error is triggered by HTTP status codes C<400> and C<500>. This class
has the following sub-classes:

=over

=item * C<Search::Elasticsearch::Error::Missing>

A resource that you requested was not found.  These errors are triggered
by the C<404> HTTP status code.

=item * C<Elastisearch::Error::Conflict>

Your request could not be performed because of some conflict.  For instance,
if you try to delete a document with a particular version number, and the
document has already changed, it will throw a C<Conflict> error.  If it can,
it will include the C<current_version> in the error vars. This error
is triggered by the C<409> HTTP status code.

=item * C<Search::Elasticsearch::Error::ContentLength>

The request body was longer than the
L<max_content_length|Search::Elasticsearch::Role::Cxn::HTTP/max_content_length>.

=back

=item * C<Search::Elasticsearch::Error::Timeout>

The request timed out.

=item * C<Search::Elasticsearch::Error::Cxn>

There was an error connecting to a node in the cluster.  This error
indicates node failure and will be retried on another node.
This error has the following sub-class:

=over

=item * C<Search::Elasticsearch::Error::Unavailable>

The current node is unable to handle your request at the moment. Your
request will be retried on another node.  This error is triggered by
the C<503> HTTP status code.

=back

=item * C<Search::Elasticsearch::Error::ClusterBlocked>

The cluster was unable to process the request because it is currently blocking,
eg there are not enough master nodes to form a cluster. This error is
triggered by the C<403> HTTP status code.

=item * C<Search::Elasticsearch::Error::Serializer>

There was an error serializing a variable or deserializing a string.

=item * C<Elasticsarch::Error::Internal>

An internal error occurred - please report this as a bug in
this module.

=back
