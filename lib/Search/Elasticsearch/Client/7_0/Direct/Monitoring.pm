# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

package Search::Elasticsearch::Client::7_0::Direct::Monitoring;

use Moo;
with 'Search::Elasticsearch::Client::7_0::Role::API';
with 'Search::Elasticsearch::Role::Client::Direct';
use namespace::clean;

__PACKAGE__->_install_api('monitoring');

1;

__END__

# ABSTRACT: Plugin providing Monitoring for Search::Elasticsearch 7.x

=head1 SYNOPSIS

    my $response = $es->monitoring( body => {...} )