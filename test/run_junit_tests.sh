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

export ES=localhost:9200

###### RUN TESTS #######

export JUNIT_OUTPUT_FILE=sync_tests.xml
run "Sync tests"        prove --harness=TAP::Harness::JUnit -l t/*/*.t

export JUNIT_OUTPUT_FILE=yaml_lwp.xml
run 'YAML: LWP'         ./test/run_yaml_tests.pl --junit

export JUNIT_OUTPUT_FILE=yaml_netcurl.xml
run 'YAML: NetCurl'     ./test/run_yaml_tests.pl  --cxn NetCurl

#########################

exit $ERROR

