use IO::Socket::SSL;
use lib 't/lib';

$ENV{ES_CXN} = 'HTTPTiny';
our $Throws_SSL = "SSL";

sub ssl_options {
    return {
        SSL_verify_mode => SSL_VERIFY_PEER,
        SSL_ca_file     => $_[0]
    };
}

do "es_sync_auth.pl";
