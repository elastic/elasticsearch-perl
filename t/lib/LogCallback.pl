use Log::Any::Adapter::Callback;
use Log::Any::Adapter;

our ( $method, $format );
Log::Any::Adapter->set(
    'Callback',
    min_level  => 'trace',
    logging_cb => sub {
        ( $method, undef, $format ) = @_;
    },
    detection_cb => sub {
        $method = shift;
    }
);

1
