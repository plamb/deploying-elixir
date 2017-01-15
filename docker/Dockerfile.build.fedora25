# This image is designed as a base image to use in creating distillery releases. It
# includes quite a few things that you would not need for just a pure runtime.
FROM fedora:25
# Fedora 25 is going to give us Erlang 19 and Node 6.9
# Elixir is at 1.3.1 and we want latest 1.3.4 so we will not install it from dnf

MAINTAINER Your Name <name@your-domain.com>

ENV REFRESHED_AT 2017-01-15
# 2017-01-15 update to elixir 1.4.0
# 2016-12-14 clean up comments and any remaining debainisms
# 2016-11-30 Refactor for Fedora 25
# 2016-11-02 updated to erlang 19 and elixir 1.3
# 2015-12-20 update erlang to 18.* so that it will pick up the latest one (18.2 isn't in repo yet)

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Get base packages, dev tools, and set the locale
RUN dnf -y update --setopt=deltarpm=false && \
    dnf -y install --setopt=deltarpm=false \
      @development-tools \
      curl \
      erlang \
      git \
      nodejs \
      unzip \
      wget  \
    && dnf clean all

# Download and Install Specific Version of Elixir
WORKDIR /elixir
RUN wget -q https://github.com/elixir-lang/elixir/releases/download/v1.4.0/Precompiled.zip && \
    unzip Precompiled.zip && \
    rm -f Precompiled.zip && \
    ln -s /elixir/bin/elixirc /usr/local/bin/elixirc && \
    ln -s /elixir/bin/elixir /usr/local/bin/elixir && \
    ln -s /elixir/bin/mix /usr/local/bin/mix && \
    ln -s /elixir/bin/iex /usr/local/bin/iex

# Install local Elixir hex and rebar
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix local.rebar --force && \
    /usr/local/bin/mix hex.info

ENV PORT 4000
ENV MIX_ENV prod
# This prevents us from installing devDependencies
# ENV NODE_ENV production
# This causes brunch to build minified and hashed assets
ENV BRUNCH_ENV production

WORKDIR /home/app/webapp
COPY . /home/app/webapp

# the phoenix.js and phoenix_html dependencies in package json require
# us to copy the whole web app in first and get dependencies before
# doing the npm install

# since this is umbrella app we need the --all to get the dependencies for all apps
# not just the umbrella app
RUN mix deps.get --all && \
   mix deps.compile --all && \
   mix compile --all && \
   mix release --env=prod

# go to our phoenix app and install node dependencies and output static assets
# do this after mix deps.get since the phoenix & phoenix_html node modules reference
# files in these dependencies
# WORKDIR /home/app/webapp/apps/search_web
# RUN npm install \
#   # && npm rebuild node-sass \
#   && node node_modules/brunch/bin/brunch build \ 
#   && mix phoenix.digest

# build the app
# WORKDIR /home/app/webapp
# RUN mix release --env=prod

# EXPOSE 4000
# CMD ["mix","phoenix.server"]
RUN pwd
RUN ls -la rel/tuscon/releases/0.1.0