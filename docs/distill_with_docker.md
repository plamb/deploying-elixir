# Distilling with Docker

- Last updated: January 2017
- Elixir 1.3.4
- Distillery 1.0
- Docker 1.12

There are a few reasons why you'd want to containerize your build step:

1. You tried to deploy a build from your dev environment (macOs) to a Linux machine and it didn't work,
2. You realized that you had NIFs (natively compiled code) in your dependencies (comeonin)
3. You had an Erlang dependency mismatch on deploy
4. You want to automate your build with a CI process

Don't feel bad, I wrote this article because I hit all those problems. But once you've containerized the build you can rein in all those problems and the CI automation step becomes much easier. We're going to create a Dockerfile that builds a Distillery release of our app and saves it to disk, it's not complicated but there are a couple of things you need to know.

Part 2 covers taking our release and "bottling" it inside a second Dockerfile for running the release. This is useful if you want to run (or test) your app in a Docker container and gives us clean separation between the build container and the deployment container. A nice bonus is that we can get a very small deployment container.

## Sample App & Dockerfiles
I've created a very simple plug application, named SamplePlugApp, that I'll use to demonstrate the build process. If you'd like to follow along the github repo is at: (https://github.com/plamb/elixir-deploy)[https://github.com/plamb/elixir-deploy]

## What's the target?

I'm going to make the assumption that you are deploying to some form of Linux. You need get specific on your deployment environment, as this will inform your decisions on the build environment.

- OS Distribution (Debian, Ubuntu, CentOs, RHEL, Fedora, Alpine, Arch...)
- OS Version (14.04, 16.04, Jessie, 7...)

You need to make sure our OS architect, version and Erlang dependencies **MATCH** in both our build container and our deployment environment. I can't put enough emphasis on *match* in the previous sentence, all sorts of weird errors can happen when you get those out of sync.

## .dockerignore

Everybody goes straight for the Dockerfile first. Don't. Create a .dockerignore file at the root of your project [the same directory with your .gitignore file]. This file tells Docker what to skip when we issue a COPY command in our Dockerfile. It may sound a bit trivial but on even a medium size apps it can offer a decent performance boost. Plus, and this is a big one, we DO NOT want to copy in our dev _build or deps directories into the Docker container. The whole point of this exercise is to completely separate out our dev build from the deploy build. Here's a sample one:

```
.dockerignore  # check and see if this is excluded by default
.git
.gitignore

# I usually have a docker directory with Dockerfiles and scripts
docker
Docker

# Mix artifacts
_build
deps
*.ez

# we're going to store our releases in the releases directory, we don't need to copy these files into the container
releases

# Generate on crash by the VM
erl_crash.dump

# Static artifacts if you're using Phoenix if it's an umbrella app change the paths
node_modules
web/static

# any other directories that have files that don't need to be included in the build
# these are specific to the sample project
docs
pages
```

## Distillery Config

By default, Distillery is going to save you releases to '_build/<$MIX_ENV>/rel/<release_name>' but we need to change that because we're going to mount our releases directory into the Docker build container and have Distillery send output there.

You need to modify rel/config.exs. [If you don't have a rel/config.exs file, you haven't set up [Distillery](https://github.com/bitwalker/distillery) yet.] Add an output_dir to the release block [it's usually at the bottom] and change the app name to match yours.

```elixir
release :sample_plug_app do
  set version: current_version(:sample_plug_app)
  set output_dir: './releases/sample_plug_app'
end
```
Note: the output_dir should be included in the .dockerignore file. If you change to a different directory make sure to also update the .dockerignore. Also make sure you change the "sample_plug_app" to the name of your app.

## Dockerfile

With our .dockerignore and updated Distillery config, there aren't any big changes to our Dockerfile and we when do a `docker run` we add a `-v ./releases:/app/releases` option so we mount the releases directory inside the docker container to persist the release to our local directory instead of inside the docker container.

Here's a sample Dockerfile, that uses the "official" Elixir layer which includes the "official" Erlang layer.

```dockerfile
# Start with the "official" Elixir build (this simplifies quite a bit here).
# This uses the "official" Erlang build (right now at 19.2) 
# on top of Debian jessie.
FROM elixir:1.3.4

MAINTAINER Your Name <name@your-domain.com>

ENV REFRESHED_AT 2016-12-31

# Install hex
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix hex.info

WORKDIR /app
COPY . /app

RUN mix deps.get

CMD ["bash"]
```

If you've cloned the [sample app](https://github.com/elixir-deploy) you can issue the following command to build a release:

```
docker build --tag=build-elixir -f docker/Dockerfile.build.elixir .
docker run -v $PWD/releases:/app/releases build-elixir mix release --env=prod
```

What does this do? First we build a Docker image using the Dockerfile we created. The build utilizes the existing "official" Elixir layer, adds hex, copies our application into the container and gets the dependencies. We tag the container with a name of "build-release". The first time your run the build is going to take a while, subsequent builds will use Docker's caching mechanisms and will go much faster. In fact, subsequent builds should only execute the COPY and RUN to get code and dependencies.

The second command, docker run, will execute the command 'mix release --env=prod' within the container we just created, which will compile and package our app. Our release tarball will be stored in releases/sample_plug_app/releases/0.1.0/sample_plug_app.tar.gz.