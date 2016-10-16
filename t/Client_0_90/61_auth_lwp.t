use lib 't/lib';

$ENV{ES_VERSION} = '0_90';
$ENV{ES_CXN} = 'LWP';
our $Throws_SSL = "Cxn";

sub ssl_options {
    return {
        verify_hostname => 1,
        SSL_ca_file     => $_[0]
    };
}

do "es_sync_auth.pl" or die( $@ || $! );
