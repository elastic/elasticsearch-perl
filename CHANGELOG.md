# Changelog
All notable changes to this project will be documented in this file.


## [7.3.0] - 2020-09-15

### Added
- New APIs for Elasticsearch 7.3.2

### Changed
- Updated HTTP::Tiny to the latest 0.076

### Removed
- Support of client 5_0
- Support of client 2_0
- Support of client 1_0
- Support of client 0_9
- Support of Hijk Cxn

### BC breaks

This is the first 7.x major release. You can read all the BC breaks from Elasticsearch 6.x [here](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/breaking-changes-7.0.html).

One of the most significative change is the **deprecation of types**. Elasticsearch 7 deprecated APIs that accept types, introduced new typeless APIs, and removed support for the `_default_` mapping. You can read more [here](https://www.elastic.co/blog/moving-from-types-to-typeless-apis-in-elasticsearch-7-0).

Regarding the Perl library there are some changes:
- `Search::Elasticsearch::Client::6_0::Scroll`:
    - removed the `scroll_in_qs` parameter. It's deprecated in 7.0.0 (see [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/scroll-api.html#scroll-api-path-params)) and it's dangerous to use it for long ID. You can use the scroll_id as a body parameter.
    - `total` is now a property of `$scroll->{total}` (not a reference anymore, since 6.80, see [#168](https://github.com/elastic/elasticsearch-perl/pull/168))
