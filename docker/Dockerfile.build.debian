# Start with the "official" Elixir build (this simplifies quite a bit here).
# This uses the "official" Erlang build (right now at 19.1.5 and includes rebar 2 & 3) 
# on top of Debian jessie.
FROM elixir:1.4.0

MAINTAINER Your Name <name@your-domain.com>

ENV REFRESHED_AT 2017-01-15
# 2017-01-15 update to elixir 1.4.0


# Install hex
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix hex.info

# This prevents us from installing devDependencies
# This causes brunch to build minified and hashed assets
ENV MIX_ENV=prod BRUNCH_ENV=production

WORKDIR /app/webapp
# make sure you've added the .dockerignore file
COPY . /app/webapp

# since this is umbrella app we need the --all to get the dependencies for all apps
# not just the umbrella app
RUN mix deps.get && \
   mix deps.compile && \
   mix compile && \
   mix release 
   