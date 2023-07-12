# CI certificates

This directory contains certificates that can be used to test against Elasticsearch in CI

## Generating new certificates using the Certificate Authority cert and key

The `ca.crt` and `ca.key` can be used to generate any other certificates that may be needed
for CI. Perhaps the easiest way to do so is using 
[`elasticsearch-certutil`](https://www.elastic.co/guide/en/elasticsearch/reference/current/certutil.html)

Using the elasticsearch docker container, run the following from the `.ci/certs` directory

```sh
docker run \
  -v "$PWD:/var/tmp" \
  --rm docker.elastic.co/elasticsearch/elasticsearch:7.6.1 \
  ./bin/elasticsearch-certutil cert \
  --ca-cert /var/tmp/ca.crt --ca-key /var/tmp/ca.key --pem \
  --out /var/tmp/bundle.zip
```

This will output a `bundle.zip` file containing a directory named `instance` containing 
`instance.crt` and `instance.key` in PEM format.

The CN Subject name can be changed using

```sh
docker run \
  -v "$PWD:/var/tmp" \
  --rm docker.elastic.co/elasticsearch/elasticsearch:7.6.1 \
  ./bin/elasticsearch-certutil cert \
  --ca-cert /var/tmp/ca.crt --ca-key /var/tmp/ca.key --pem \
  --out /var/tmp/bundle.zip \
  --name foo
```

The directory in `bundle.zip` will now be named `foo` and contain 
`foo.crt` and `foo.key` in PEM format.

Additional DNS and IP SAN entries can be added with `--dns` and `--ip`, respectively.

```sh
docker run \
  -v "$PWD:/var/tmp" \
  --rm docker.elastic.co/elasticsearch/elasticsearch:7.6.1 \
  ./bin/elasticsearch-certutil cert \
  --ca-cert /var/tmp/ca.crt --ca-key /var/tmp/ca.key --pem \
  --out /var/tmp/bundle.zip \
  --dns instance --dns localhost --dns es1 --ip 127.0.0.1 --ip ::1
```
