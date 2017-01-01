# Distilling with Docker Part 1: A Good Begining

- Last updated: January 2017
- Elixir 1.3.4
- Distillery 1.0
- Docker 1.12

## Why

There are a few reasons why you'd want to containerize your build step:

1. You tried to deploy a build from your dev environment (macOs) to a Linux machine and it didn't work,
2. You realized that you had NIFs (natively compiled code) in your dependencies (comeonin)
3. You had an Erlang dependency mismatch on deploy
4. You want to automate your build with a CI process

Don't feel bad, I wrote this article because I hit all those problems. But once you've containerized the build you can rein in all those problems and the CI automation step becomes much easier. We're going to create a Dockerfile that builds a Distillery release of our app and saves it to disk, it's not complicated but there are a couple of things you need to know.

## Sample App & Dockerfiles
I've created a very simple plug application, named SamplePlugApp, that I'll use to demonstrate the build process. If you'd like to follow along the github repo is at: (https://github.com/plamb/elixir-deploy)[https://github.com/plamb/elixir-deploy]

## Deploying to?

I'm going to make the assumption that you are deploying to some form of Linux and for this first part we're going to target Debian Jessie. In part 2 we'll cover other targets but we need to start with something easy and get it working first, then we can iterate from there. Debian Jessie just happens to be what the ["official" Erlang docker image](https://hub.docker.com/_/erlang/) and ["official" Elixir docker image](https://hub.docker.com/_/elixir/) is built on, so that's what we're going to use.

Keep in mind that your docker build environment needs to **match** your deployment environment. Part 2 covers other targets.

## .dockerignore

Everybody goes straight for the Dockerfile first. Don't. Create a .dockerignore file at the root of your project. This file tells Docker what to skip when we issue a COPY command in our Dockerfile. It may sound a bit trivial but on even a medium size apps it can offer a decent performance boost. Plus, and this is a big one, we DO NOT want to copy in our dev _build or deps directories into the Docker container. The whole point of this exercise is to completely separate out our dev build from the deploy build. We're wanting to exclude everything we possibly can and no more. Here's a sample one:

```
.dockerignore  # check and see if this is excluded by default
.git
.gitignore
.log
tmp

# I usually have a docker directory with Dockerfiles and scripts
docker

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
```

## Distillery Config

By default, Distillery is going to save releases to '_build/<$MIX_ENV>/rel/<release_name>' but we need to change that because we're going to mount our releases directory into the Docker build container and have Distillery send output there.

You need to modify rel/config.exs. [If you don't have a rel/config.exs file, you haven't set up [Distillery](https://github.com/bitwalker/distillery) yet.] Add an output_dir to the release block [it's usually at the bottom] and change the app name to match yours.

```elixir
release :sample_plug_app do
  set version: current_version(:sample_plug_app)
  set output_dir: './releases/sample_plug_app'
end
```
Note: the output_dir should be included in the .dockerignore file. If you change to a different directory make sure to also update the .dockerignore. Also, make sure you change the "sample_plug_app" to the name of your app.

## Dockerfile

With our .dockerignore and updated Distillery config, we're finally to our Dockerfile. I create a docker directory and put them in there. The one below is [docker/Dockerfile.build.elixir](./docker/Dockerfile.build.elixir). It uses the "official" Elixir layer which includes the "official" Erlang layer which is based on Debian Jessie.

```dockerfile
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

You can then issue the following command to build a release. If you've been testing Distillery and have output in the releases directory, please do a `mix release.clean` before the `docker build` and `docker run`.

```
docker build --tag=build-elixir -f docker/Dockerfile.build.elixir .
docker run -v $PWD/releases:/app/releases build-elixir mix release --env=prod
```

What does this do? First, we build a Docker image using the Dockerfile we created. The build utilizes the existing "official" Elixir layer, adds hex, copies our application into the container and gets the dependencies. We tag the container with a name of "build-release". The first time you run the build step it's is going to take a while, subsequent builds will use Docker's caching mechanisms and will go much faster. In fact, subsequent builds should only execute the COPY and RUN to get code and dependencies.

The second command, `docker run`, will execute the command `mix release --env=prod` within the container we just created, which will compile and package our app. Our release tarball will be stored in releases/sample_plug_app/releases/0.1.0/sample_plug_app.tar.gz.

# Mix It Up
Now that we've got a working build process we need to take another 3 minutes and add a mix task to automate it....

## Q & A

There's going to be some question and I'll try and answer a few right up front.

#### But...what about?
Yes, there's a couple of other ways we could have done the Dockerfile and the commands. Particularly, why didn't we just use another volume and map our source directory right into the container? Mostly, because I really, really want a separation between our dev, build, test and prod environments. I did not want any local dev bits getting into our build.

#### Why can't you do it all with the build command?
You can only mount volumes when running the `docker run` command. To get around this, we could have done a `RUN mix release` in the Dockerfile and then used a `docker cp` to copy the file out. But this means that the commands run on the container are hard coded into the container. Instead, we use a `CMD [bash]` to tell the container what to execute when a `docker run` is issued without any arguments, we then override that command with the final option `mix release --env=prod`. This gives us an easy way to specify options and commands to the container, i.e. `mix release.upgrade --env=prod`.

#### But I want to git clone the source into the container.
At some point, I might write that how-to, maybe. But I'd suggest you let that automagically happen with your CI system instead. In the meantime, you might take a look at [Building docker images with two Dockerfiles](http://blog.tomecek.net/post/build-docker-image-in-two-steps).