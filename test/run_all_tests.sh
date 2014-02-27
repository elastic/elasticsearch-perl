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

run "Sync tests"        prove -l t/*/*.t

run 'YAML: HTTPTiny'    ./test/run_yaml_tests.pl

run 'YAML: NetCurl'     ./test/run_yaml_tests.pl  --cxn NetCurl

#########################

exit $ERROR

