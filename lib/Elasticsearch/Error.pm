package Elasticsearch::Error;

use Moo;

our $DEBUG = 0;

@Elasticsearch::Error::Internal::ISA       = __PACKAGE__;
@Elasticsearch::Error::Param::ISA          = __PACKAGE__;
@Elasticsearch::Error::NoNodes::ISA        = __PACKAGE__;
@Elasticsearch::Error::ClusterBlocked::ISA = __PACKAGE__;
@Elasticsearch::Error::Request::ISA        = __PACKAGE__;
@Elasticsearch::Error::Timeout::ISA        = __PACKAGE__;
@Elasticsearch::Error::Cxn::ISA     = __PACKAGE__;
@Elasticsearch::Error::Serializer::ISA     = __PACKAGE__;

@Elasticsearch::Error::Conflict::ISA
    = ( 'Elasticsearch::Error::Request', __PACKAGE__ );

@Elasticsearch::Error::Missing::ISA
    = ( 'Elasticsearch::Error::Request', __PACKAGE__ );

@Elasticsearch::Error::NotReady::ISA
    = ( 'Elasticsearch::Error::Cxn', __PACKAGE__ );

@Elasticsearch::Error::ContentLength::ISA
    = ( __PACKAGE__, 'Elasticsearch::Error::Request' );

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

