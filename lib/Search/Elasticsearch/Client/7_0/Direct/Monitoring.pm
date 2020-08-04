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