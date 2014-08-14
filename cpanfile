requires "Any::URI::Escape" => "0";
requires "AnyEvent::HTTP" => "0";
requires "Data::Dumper" => "0";
requires "Encode" => "0";
requires "File::Temp" => "0";
requires "HTTP::Headers" => "0";
requires "HTTP::Parser::XS" => "0";
requires "HTTP::Request" => "0";
requires "HTTP::Tiny" => "0.043";
requires "Hijk" => "0.12";
requires "IO::Select" => "0";
requires "IO::Socket" => "0";
requires "IO::Socket::SSL" => "0";
requires "IO::Uncompress::Inflate" => "0";
requires "JSON::MaybeXS" => "1.002002";
requires "JSON::PP" => "0";
requires "LWP::UserAgent" => "0";
requires "List::Util" => "0";
requires "Log::Any" => "0";
requires "Log::Any::Adapter" => "0";
requires "MIME::Base64" => "0";
requires "Module::Runtime" => "0";
requires "Moo" => "1.003";
requires "Moo::Role" => "0";
requires "Net::Curl::Easy" => "0";
requires "POSIX" => "0";
requires "Package::Stash" => "0";
requires "Promises" => "0.93";
requires "Scalar::Util" => "0";
requires "Sub::Exporter" => "0";
requires "Time::HiRes" => "0";
requires "Try::Tiny" => "0";
requires "URI" => "0";
requires "namespace::clean" => "0";
requires "overload" => "0";
requires "strict" => "0";
requires "warnings" => "0";
recommends "URI::Escape::XS" => "0";

on 'build' => sub {
  requires "TAP::Harness::JUnit" => "0";
  requires "Test::More" => "0.98";
};

on 'test' => sub {
  requires "AE" => "0";
  requires "EV" => "0";
  requires "Log::Any::Adapter::Callback" => "0";
  requires "Test::Deep" => "0";
  requires "Test::Exception" => "0";
  requires "Test::More" => "0.98";
  requires "lib" => "0";
};

on 'test' => sub {
  recommends "Cpanel::JSON::XS" => "0";
  recommends "JSON::XS" => "2.26";
  recommends "Mojo::IOLoop" => "0";
  recommends "Mojo::UserAgent" => "0";
};
