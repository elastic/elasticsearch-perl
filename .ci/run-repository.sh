#!/usr/bin/env bash
#
# Called by entry point `run-test` use this script to add your repository specific test commands
#
# Once called Elasticsearch is up and running
#
# Its recommended to call `imports.sh` as defined here so that you get access to all variables defined there
#
# Any parameters that test-matrix.yml defines should be declared here with appropiate defaults

script_path=$(dirname $(realpath -s $0))
source $script_path/functions/imports.sh
set -euo pipefail

PERL_VERSION=${PERL_VERSION-5.32}
ELASTICSEARCH_URL=${ELASTICSEARCH_URL-"$elasticsearch_url"}

echo -e "\033[34;1mINFO:\033[0m VERSION: ${STACK_VERSION}\033[0m"
echo -e "\033[34;1mINFO:\033[0m TEST_SUITE: ${TEST_SUITE}\033[0m"
echo -e "\033[34;1mINFO:\033[0m URL ${ELASTICSEARCH_URL}\033[0m"
echo -e "\033[34;1mINFO:\033[0m RUNSCRIPTS: ${RUNSCRIPTS}\033[0m"
echo -e "\033[34;1mINFO:\033[0m PERL_VERSION ${PERL_VERSION}\033[0m"
echo -e "\033[34;1mINFO:\033[0m CLIENT_VER ${CLIENT_VER}\033[0m"

echo -e "\033[34;1mINFO:\033[0m pinging Elasticsearch ..\033[0m"
curl --insecure --fail $external_elasticsearch_url/_cluster/health?pretty

echo -e "\033[32;1mSUCCESS:\033[0m successfully started the ${STACK_VERSION} stack.\033[0m"

echo -e "\033[1m>>>>> Build docker container >>>>>>>>>>>>>>>>>>>>>>>>>>>>>\033[0m"

docker build \
  --no-cache \
  --file .ci/Dockerfile \
  --tag elastic/elasticsearch-perl \
  --build-arg PERL_VERSION=${PERL_VERSION} \
  .

echo -e "\033[1m>>>>> Run test:integration >>>>>>>>>>>>>>>>>>>>>>>>>>>>>\033[0m"

repo=$(realpath $(dirname $(realpath -s $0))/../)

docker run \
  --network=${network_name} \
  --workdir="/usr/src/app" \
  --volume=${repo}/tests:/usr/src/app/tests \
  --env STACK_VERSION=${STACK_VERSION} \
  --env TEST_SUITE=${TEST_SUITE} \
  --env PERL_VERSION=${PERL_VERSION} \
  --env ELASTICSEARCH_URL=${ELASTICSEARCH_URL} \
  --env CLIENT_VER=${CLIENT_VER} \
  --ulimit nofile=65535:65535 \
  --name elasticsearch-perl \
  --rm \
  elastic/elasticsearch-perl