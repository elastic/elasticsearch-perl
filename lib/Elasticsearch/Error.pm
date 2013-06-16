package Elasticsearch::Error;

use Moo;

our $DEBUG = 0;

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

    my ( undef, $file, $line ) = caller($caller);
    my $self = bless {
        type => $type,
        text => $msg,
        line => $line,
        file => $file,
        vars => $vars,
    }, $error_class;

    $self->{stacktrace} = $self->stacktrace( $caller + 1 )
        if $DEBUG > 1;
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
    local $Data::Dumper::Terse = 1;
    $DEBUG and local $Data::Dumper::Indent = 1;

    unless ( $self->{msg} ) {
        $self->{msg} = sprintf( "[%s] ** %s, at %s line %d.\n",
            @{$self}{ 'type', 'text', 'file', 'line' } );

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
1;

