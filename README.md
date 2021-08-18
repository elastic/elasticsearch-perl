# Elasticsearch Perl client

[![Build Status](https://travis-ci.org/elastic/elasticsearch-perl.svg?branch=master)](https://travis-ci.org/elastic/elasticsearch-perl)

Search::Elasticsearch is the official Perl API for Elasticsearch. 
The full documentation is available on https://metacpan.org/module/Search::Elasticsearch.

## Features

* Full support for all Elasticsearch APIs
* HTTP backend (blocking and asynchronous with [Search::Elasticsearch::Async](https://metacpan.org/module/Search::Elasticsearch::Async))
* Robust networking support which handles load balancing, failure detection and failover
* Good defaults
* Helper utilities for more complex operations, such as bulk indexing, scrolled searches and reindexing.
* Logging support via `Log::Any`
* Compatibility with the [official clients](https://www.elastic.co/guide/en/elasticsearch/client/index.html)
* Easy extensibility

## Install

```
cpanm Search::Elasticsearch
```

## Compatibility

Language clients are forward compatible; meaning that clients support communicating
with greater minor versions of Elasticsearch. Elastic language clients are also backwards
compatible with lesser supported minor Elasticsearch versions.

## License

This software is licensed under the [Apache 2 license](LICENSE).

