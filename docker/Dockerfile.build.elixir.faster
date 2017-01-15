# Start with the "official" Elixir build (this simplifies quite a bit here).
# This uses the "official" Erlang build (right now at 19.2) 
# on top of Debian jessie.
FROM elixir:1.4.0

MAINTAINER Your Name <name@your-domain.com>

ENV REFRESHED_AT 2017-01-15
# 2017-01-15 update to elixir 1.4.0

# Install hex
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix local.rebar --force && \
    /usr/local/bin/mix hex.info

WORKDIR /app

# Copy in only our mix files, the run will only happen if they've changed
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Now copy in the rest of the app
COPY . .

CMD ["bash"]
   