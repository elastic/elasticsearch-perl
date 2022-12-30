# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

package MockCxn;

use strict;
use warnings;
use Search::Elasticsearch::Role::Cxn qw(PRODUCT_CHECK_HEADER PRODUCT_CHECK_VALUE);

our $PRODUCT_CHECK_VALUE = $Search::Elasticsearch::Role::Cxn::PRODUCT_CHECK_VALUE;
our $PRODUCT_CHECK_HEADER = $Search::Elasticsearch::Role::Cxn::PRODUCT_CHECK_HEADER;
our $VERSION = $Search::Elasticsearch::VERSION;

use Data::Dumper;
use Moo;
with 'Search::Elasticsearch::Role::Cxn', 'Search::Elasticsearch::Role::Is_Sync';

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
        {
            'content-type' => 'application/json',
            $PRODUCT_CHECK_HEADER => $PRODUCT_CHECK_VALUE
        }
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
    return Search::Elasticsearch->new(
        cxn            => '+MockCxn',
        cxn_pool       => $pool,
        mock_responses => \@_,
        randomize_cxns => 0,
        log_to         => $trace,
        %$params,
    )->transport;
}

1
