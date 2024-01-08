ARG PERL_VERSION=5.32
FROM perl:${PERL_VERSION}

WORKDIR /usr/src/app

# Install git, unzip
RUN echo "--- Install git, unzip"
RUN apt-get update && \
    apt-get install -y --no-install-recommends git unzip

# Print PERL version
RUN echo "--- PERL version"
RUN perl -v

COPY . .

# Install cpanm dependencies
RUN echo "--- Install cpanm dependencies"
RUN cpanm --quiet --notest --installdeps .

# Install Dist::Zilla
RUN echo "--- Install Dist::Zilla"
RUN cpanm Dist::Zilla --quiet --notest

# Install dependencies
RUN echo "--- Install cpanm missing dependencies"
RUN dzil authordeps --missing | cpanm --quiet --notest
RUN dzil listdeps --missing | cpanm --quiet --notest
RUN cd dist && dzil authordeps --missing | cpanm --quiet --notest
RUN cd dist && dzil listdeps --missing | cpanm --quiet --notest

CMD ["bash", ".buildkite/yaml-tests.sh"]
