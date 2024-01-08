#!/usr/bin/env bash

# Checkout the YAML test from Elasticsearch tag
echo "--- Checkout YAML test from Elasticsearch"
util/checkout_yaml_test.pl

# Run YAML tests
echo "--- Run YAML tests"
test/run_yaml_tests.pl