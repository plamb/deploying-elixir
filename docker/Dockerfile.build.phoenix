# Start with the "official" Elixir build (this simplifies quite a bit here).
# This uses the "official" Erlang build (right now at 19.1.5 and includes rebar 2 & 3) 
# on top of Debian jessie.
FROM elixir:1.4.0

MAINTAINER Paul Lamb <paul@oil-law.com>

ENV REFRESHED_AT 2017-01-15
# 2017-01-15 update to elixir 1.4.0
# 2017-01-01 Switch to copying from "official" node 
# 2016-11-03 Switch to "official" Elixir Dockerfile for base and node 6.7.0
# 2016-11-02 updated to Erlang 19 and Elixir 1.3
# 2015-12-20 update Erlang to 18.* so that it will pick up the latest one (18.2 isn't in repo yet)

# Install hex
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix hex.info


# -----------------------------------------------------------------------------
# node:6.9.2
# https://hub.docker.com/_/node/
RUN apt-get update && apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bzip2 \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgdbm-dev \
		libgeoip-dev \
		libglib2.0-dev \
		libjpeg-dev \
		libkrb5-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libmysqlclient-dev \
		libncurses-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		xz-utils \
		zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.9.2

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs
# -----------------------------------------------------------------------------


# This prevents us from installing devDependencies
# This causes brunch to build minified and hashed assets
ENV MIX_ENV=prod BRUNCH_ENV=production

WORKDIR /app
COPY . /app

RUN mix deps.get && \
   mix deps.compile && \
   mix compile

# install node dependencies and output static assets
# do this after mix deps.get since the phoenix & phoenix_html node modules reference
# files in these dependencies
RUN npm install \
  && npm rebuild node-sass \
  && node node_modules/brunch/bin/brunch build \ 
  && mix phoenix.digest

CMD ["bash"]