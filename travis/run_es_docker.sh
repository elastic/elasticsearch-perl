#!/bin/sh
if [ -z $ES_VERSION ]; then
    echo "No ES_VERSION specified";
    exit 1;
fi;

docker pull docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
docker network create esnet;
docker run \
  --rm \
  --publish 9200:9200 \
  --env "node.attr.testattr=test" \
  --env "path.repo=/tmp" \
  --env "repositories.url.allowed_urls=http://snapshot.*" \
  --env "discovery.type=single-node" \
  --network=esnet \
  --name=elasticsearch \
  --detach \
  docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
docker run --network esnet --rm appropriate/curl --max-time 120 --retry 120 --retry-delay 1 --retry-connrefused --show-error --silent http://elasticsearch:9200
