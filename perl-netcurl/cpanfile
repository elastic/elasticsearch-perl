requires "Elasticsearch" => "0.76";
requires "Elasticsearch::Role::Cxn::HTTP" => "0";
requires "Moo" => "0";
requires "Net::Curl::Easy" => "0";
requires "Try::Tiny" => "0";
requires "namespace::clean" => "0";
recommends "JSON::XS" => "0";
recommends "URI::Escape::XS" => "0";

on 'build' => sub {
  requires "Test::More" => "0.98";
};

on 'build' => sub {
  recommends "ExtUtils::PkgConfig" => "0";
};

on 'test' => sub {
  requires "Data::Dumper" => "0";
  requires "Elasticsearch::Bulk" => "0";
  requires "Elasticsearch::Scroll" => "0";
  requires "Exporter" => "0";
  requires "File::Basename" => "0";
  requires "File::Temp" => "0";
  requires "Log::Any::Adapter" => "0";
  requires "Log::Any::Adapter::Callback" => "0";
  requires "Sub::Exporter" => "0";
  requires "Test::Deep" => "0";
  requires "Test::Exception" => "0";
  requires "Test::More" => "0";
  requires "YAML" => "0";
  requires "lib" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
};
