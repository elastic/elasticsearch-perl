use Log::Any::Adapter::Callback;
use Log::Any::Adapter;

our ( $method, $format, @params );
Log::Any::Adapter->set(
    'Callback',
    min_level  => 'trace',
    logging_cb => sub {
        ( $method, undef, $format, @params ) = @_;
    },
    detection_cb => sub {
        $method = shift;
    }
);

1
