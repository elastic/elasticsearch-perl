# Changelog
All notable changes to this project will be documented in this file.

## [8.12.0] - 2024-01-25

- New APIs for Elasticsearch 8.12.0, including the [ES|QL](https://www.elastic.co/guide/en/elasticsearch/reference/current/esql.html) support 
- Fixed issue [#227](https://github.com/elastic/elasticsearch-perl/issues/227) for the `x-elastic-product` check on 7.x instances
- Fixed issue [#211](https://github.com/elastic/elasticsearch-perl/issues/211) for the SSL verification in HTTP::Tiny

## [8.0.0] - 2022-12-29

### Added

- New APIs for Elasticsearch 8.0.0
- Added the `elastic_cloud_api_key` and `token_api` in Elasticsearch constructor [17d661a](https://github.com/elastic/elasticsearch-perl/commit/17d661a72e001e5eeb68d13a74edd7b72ebf5731)
- Added the product check in Elasticsearch response [acb25d6](https://github.com/elastic/elasticsearch-perl/commit/acb25d6669d8969e1ff27fa19ee89a72ea6b8cd4)
- Updated the documentation with Elastic Cloud [17b70e8](https://github.com/elastic/elasticsearch-perl/commit/17b70e85213a21a2acceb1bea2478c4ac2c2a301) and EOL announcement [#226](https://github.com/elastic/elasticsearch-perl/pull/226)

### Removed

- Support of client 6_0

