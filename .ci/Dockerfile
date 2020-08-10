ARG PERL_VERSION=5.32
FROM perl:${PERL_VERSION}

WORKDIR /usr/src/app

# Install git
RUN apt-get update && \
    apt-get install -y --no-install-recommends git

# Print PERL version
RUN perl -v

COPY . .

# Install Dist::Zilla
RUN cpanm Dist::Zilla --quiet --notest

# Install dependencies
RUN dzil authordeps --missing | cpanm --quiet --notest
RUN dzil listdeps --missing | cpanm --quiet --notest
RUN cd dist && dzil authordeps --missing | cpanm --quiet --notest
RUN cd dist && dzil listdeps --missing | cpanm --quiet --notest

# Updating elasticsearch submodule
RUN git submodule update --init --recursive

CMD ["bash", ".ci/yaml-tests.sh"]