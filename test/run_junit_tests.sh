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
run "Sync tests"        prove --harness=TAP::Harness::JUnit -l t/*/*.t

export JUNIT_OUTPUT_FILE=yaml_lwp.xml
run 'YAML: LWP'         ./test/run_yaml_tests.pl --junit

export JUNIT_OUTPUT_FILE=yaml_netcurl.xml
run 'YAML: NetCurl'     ./test/run_yaml_tests.pl  --cxn NetCurl

export ES_BODY='POST'

export JUNIT_OUTPUT_FILE=sync_post.xml
run 'Sync tests - POST body' prove --harness=TAP::Harness::JUnit -l t/*/*.t

export JUNIT_OUTPUT_FILE=yaml_post.xml
run 'YAML::LWP - POST body' ./test/run_yaml_tests.pl --junit

perl -e 'exit $ENV{ES_VERSION}=~/^0.90.(10|[0-9])$/ ? 1 : 0';
if [ $? -eq 1 ];
    then echo "SKIPPING body-as-source: $ES_VERSION"
    exit $ERROR
fi

export ES_BODY='source'

export JUNIT_OUTPUT_FILE=sync_source.xml
run 'Sync tests - source body' prove --harness=TAP::Harness::JUnit -l t/*/*.t

export JUNIT_OUTPUT_FILE=yaml_post.xml
run 'YAML::LWP - source body' ./test/run_yaml_tests.pl --junit

#########################

exit $ERROR

