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

##### INSTALL DEPS #####
cd perl
run "Install main deps" cpanm --installdeps --notest --with-recommends .

cd ../perl-netcurl
run "Install NetCurl deps" cpanm --installdeps --notest --with-recommends .

#cd ../perl-async
#run "Install Async deps" cpanm --installdeps --notest --with-recommends .
#cd ..

exit $ERROR
