# Distilling with Docker Part 2: Build it Faster

- Last updated: January 2017
- Elixir 1.4.0
- Distillery 1.1.0
- Docker 1.12

In [Part 1](./docs/distill_with_docker_pt1.md) we setup a basic build process for creating Elixir releases with [Distillery](https://github.com/bitwalker/distillery). Now that we've got it working, let's make it faster.

##Caching Layers
We're going to make a change to our Dockerfile and add the mix.exs and mix.lock file in it's own layer.

```dockerfile
FROM elixir:1.4.0

MAINTAINER Your Name <name@your-domain.com>

ENV REFRESHED_AT 2017-01-15

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
```

Since each docker step is dependent on the previous one, we use the inherent caching in Docker to only execute a step if something has change. Thus the `RUN mix do deps.get, deps.compile` only gets executed if the files in preceding COPY command have changed.

# See Also
[Distilling with Docker, Part 1: A Good Begining](./distill_with_docker_pt1.md)

[Distilling with Docker, Part 2: Build it Faster](./distill_with_docker_pt2.md)

[Distilling with Docker, Part 3: Comments and Q&A](./distill_with_docker_pt3.md)
