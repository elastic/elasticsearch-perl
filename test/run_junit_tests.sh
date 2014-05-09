#!/bin/bash

ERROR=0;
function run {
    echo
    echo "==============================================="
    echo $1
    echo "==============================================="
    echo
    shift
    $@
    if [ $? -eq 0 ]; then return; fi
    ERROR=1
}

###### RUN TESTS #######

export JUNIT_OUTPUT_FILE=sync_tests.xml
run "Module tests"        prove --harness=TAP::Harness::JUnit -l t/*/*.t

export JUNIT_OUTPUT_FILE=yaml_lwp.xml
run 'YAML: HTTPTiny'    ./test/run_yaml_tests.pl --junit

export JUNIT_OUTPUT_FILE=yaml_netcurl.xml
run 'YAML: NetCurl'     ./test/run_yaml_tests.pl  --junit --cxn NetCurl

export JUNIT_OUTPUT_FILE=yaml_hijk.xml
run 'YAML: Hijk'        ./test/run_yaml_tests.pl  --junit --cxn Hijk

export JUNIT_OUTPUT_FILE=yaml_aehttp.xml
run 'YAML: AEHTTP'      ./test/run_yaml_tests.pl  --junit --async --cxn AEHTTP

export JUNIT_OUTPUT_FILE=yaml_mojo.xml
run 'YAML: Mojo'        ./test/run_yaml_tests.pl  --junit --async --cxn Mojo

export ES_BODY='POST'

export JUNIT_OUTPUT_FILE=sync_post.xml
run 'Module tests - POST body' prove --harness=TAP::Harness::JUnit -l t/*/*.t

export JUNIT_OUTPUT_FILE=yaml_post.xml
run 'YAML::HTTPTiny - POST body' ./test/run_yaml_tests.pl --junit

perl -e 'exit $ENV{ES_VERSION}=~/^0.90.(10|[0-9])$/ ? 1 : 0';
if [ $? -eq 1 ];
    then echo "SKIPPING body-as-source: $ES_VERSION"
    exit $ERROR
fi

export ES_BODY='source'

export JUNIT_OUTPUT_FILE=sync_source.xml
run 'Module tests - source body' prove --harness=TAP::Harness::JUnit -l t/*/*.t

export JUNIT_OUTPUT_FILE=yaml_source.xml
run 'YAML::HTTPTiny - source body' ./test/run_yaml_tests.pl --junit

#########################

exit $ERROR

