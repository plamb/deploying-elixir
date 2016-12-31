# Distilling with Docker

- January 2017
- Elixir 1.3.4
- Distillery 1.0
- Docker 1.12

There are a few reasons why you'd want to containerize your build step:

1. You tried to deploy a build from your dev environment (macOs) to a Linux machine and it didn't work,
2. You realized that you had NIFs (natively compiled code) in your dependencies (comeonin)
3. You had an Erlang dependency mismatch on deploy
4. You want to automate your build with a CI process

Don't feel bad, I wrote this article because I hit all those problems. But once you've containerized the build the CI automation step becomes much easier. We're going to create a Dockerfile that builds a Distillery release of our app and saves it to disk.

In Part 2, covers creating a second Dockerfile for running the release. This is useful if you want to run (or test) your app in a Docker container and gives us clean separation between the build container and the deployment container. A nice bonus is that we get a very small deployment container.

## Sample App & Dockerfiles
I've create a very simple plug application, named Tuscon, that I'll use to demostrate the build process. If you'd like to follow along the github repo is at: (https://github.com/plamb/elixir-deploy)[https://github.com/plamb/elixir-deploy]

## First

I'm going to make the assumption that you are deploying to some form of Linux. But first, before you read anything else, we need specifics on your deployment environment:

-OS Distribution (Debian, Ubuntu, CentOs, RHEL, Fedora, Alpine, Arch...)
-OS Version (14.04, 16.04, Jessie, 7...)

We need to make sure our OS architect, version and Erlang dependencies **MATCH** in both our build container and our deployment environment. I can't put enough emphasis on *match* in the previous sentence, all sorts of weird errors can happen when you get those out of sync.

## .dockerignore

Everybody goes straight for the Dockerfile first. Don't. Create a .dockerignore file at the root of your project [the same directory with your .gitignore file]. This file tells Docker what to skip when we issue a COPY command in our Dockerfile. It may sound  a bit trivial but on even a medium size apps it can offer a decent performance boost. Plus, and this is a big one, we DO NOT want to copy in our dev _build or deps directories into the Docker container. The whole point of this exercise is to completely seperate out our dev build from the deploy build. Here's a sample one:

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

By default, distillery is going to save you releases to '_build/<$MIX_ENV>/rel/<release_name>' but we need to change that because we're going to mount our releases directory into the Docker build container and have Distillery send output there.

You need to modify rel/config.exs. [If you don't have a rel/config.exs file, you haven't set up Distillery yet.] Add an output_dir to the release block [it's usually at the bottom] and change the app name to match yours.

```elixir
release :myumbrella do
  set version: current_version(:myumbrella)
  set output_dir: './releases/myumbrella'
end
```
Note: the output_dir should be included in the .dockerignore file.

## Dockerfile

With our .dockerignore and updated Distillery config, there aren't any big changes to our Dockerfile and we when do a `docker run` we add a `-v ./releases` option so we mount the releases directory inside the docker container to save the release.

Here's a sample Dockerfile, that uses the "official" Elixir layer which includes the "official" Erlang layer.

```dockerfile
FROM elixir:1.3.4

MAINTAINER Your Name <name@your-domain.com>

ENV REFRESHED_AT 2016-12-30

# Install hex
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix hex.info

# This prevents us from installing devDependencies
# This causes brunch to build minified and hashed assets
ENV MIX_ENV=prod BRUNCH_ENV=production

WORKDIR /app
# make sure you've added the .dockerignore file to the root of the app
COPY . /app

# since this is umbrella app we need the --all to get the dependencies for all apps
# not just the umbrella app
RUN mix deps.get && \
   mix deps.compile && \
   mix compile && \
   mix release 
```

If you've cloned the (sample app)[https://github.com/elixir-deploy] you can issue the following command to build a release:

```
docker build ...
```

Which will create a tuson.tar.gz file in the directory releases/tuscon/....