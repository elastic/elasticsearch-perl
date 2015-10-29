use Log::Any::Adapter::Callback 0.09;
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
