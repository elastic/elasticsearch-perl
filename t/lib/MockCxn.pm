package MockCxn;

use strict;
use warnings;

our $VERSION = $Elasticsearch::VERSION;

use Data::Dumper;
use Moo;
with 'Elasticsearch::Role::Cxn', 'Elasticsearch::Role::Cxn::HTTP',
    'Elasticsearch::Role::Is_Sync';

use Sub::Exporter -setup => {
    exports => [ qw(
            mock_static_client
            mock_sniff_client
            mock_noping_client
            )
    ]
};

our $i = 0;

has 'mock_responses' => ( is => 'rw', required => 1 );
has 'marked_live'    => ( is => 'rw', default  => sub {0} );
has 'node_num'       => ( is => 'ro', default  => sub { ++$i } );

#===================================
sub BUILD {
#===================================
    my $self = shift;
    $self->logger->debugf( "[%s-%s] CREATED", $self->node_num, $self->host );
}

#===================================
sub error_from_text { return $_[2] }
#===================================

#===================================
sub perform_request {
#===================================
    my $self = shift;

    my $params   = shift;
    my $response = shift @{ $self->mock_responses }
        or die "Mock responses exhausted";

    if ( my $node = $response->{node} ) {
        die "Mock response handled by wrong node ["
            . $self->node_num . "]: "
            . Dumper($response)
            unless $node eq $self->node_num;
    }

    my $log_msg;

    # Sniff request
    if ( my $nodes = $response->{sniff} ) {
        $log_msg = "SNIFF: [" . ( join ", ", @$nodes ) . "]";
        $response->{code} ||= 200;
        my $i = 1;
        unless ( $response->{error} ) {
            $response->{content} = $self->serializer->encode(
                {   nodes => {
                        map {
                            'node_'
                                . $i++ => { http_address => "inet[/$_]" }
                        } @$nodes
                    }
                }
            );
        }
    }

    # Normal request
    elsif ( $response->{code} ) {
        $log_msg = "REQUEST: " . ( $response->{error} || $response->{code} );
    }

    # Ping request
    else {
        $log_msg = "PING: " . ( $response->{ping} ? 'OK' : 'NOT_OK' );
        $response
            = $response->{ping}
            ? { code => 200 }
            : { code => 500, error => 'Cxn' };
    }

    $self->logger->debugf( "[%s-%s] %s", $self->node_num, $self->host,
        $log_msg );

    return $self->process_response(
        $params,                 # request
        $response->{code},       # code
        $response->{error},      # msg
        $response->{content},    # body
        { 'content-type' => 'application/json' }
    );
}

#### EXPORTS ###

my $trace
    = !$ENV{TRACE}       ? undef
    : $ENV{TRACE} eq '1' ? 'Stderr'
    :                      [ 'File', $ENV{TRACE} ];

#===================================
sub mock_static_client { _mock_client( 'Static',         @_ ) }
sub mock_sniff_client  { _mock_client( 'Sniff',          @_ ) }
sub mock_noping_client { _mock_client( 'Static::NoPing', @_ ) }
#===================================

#===================================
sub _mock_client {
#===================================
    my $pool   = shift;
    my $params = shift;
    $i = 0;
    return Elasticsearch->new(
        cxn            => '+MockCxn',
        cxn_pool       => $pool,
        mock_responses => \@_,
        randomize_cxns => 0,
        log_to         => $trace,
        %$params,
    )->transport;
}

1
