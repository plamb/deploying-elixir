# Deploying Elixir

I had some thoughts about deploying Elixir and decided to start putting them together. I like to start off small and see what grows. So there's a tiny sample plug app in lib, the content is in the docs directory, and the sample Dockerfiles are in docker. 

I do tend to be a bit opinionated but I'm constantly looking for better ideas, so if there's something that you don't like or think could be better, please open an issue and create a pull request.

**Disclaimer:** this isn't intended to be a complete copy/paste deployment solution. It's a set of concepts and ideas that you can implement as needed.

### Overview

Here's the overview of the process:

- Build our app using [Distillery](https://github.com/bitwalker/distillery) to create our release
- The build is going to happen inside a Docker container
- Deploy to a Docker container or VPS/Bare Metal Host

### Things you need to know

If you're coming from a language like Ruby or Node there's a few differences in deploying an Elixir application. Each of these can cause problems on their own but are easy to work around.

1. there's going to be a compile phase (and possibly asset building too),
2. that compile/build is going to output an Erlang deployable, and
3. the build environment (OS and version) must **match** the deployment/production environment (OS and version). 

I don't cover installing [Docker](https://docs.docker.com/engine/installation/) or setting up [Distillery](https://github.com/bitwalker/distillery), there's a lot of good documentation there already.

[**Note:** Item #3 is probably going to cause some of you some heartburn because it's not absolutely 100% true. While there are some exceptions, treat it's completely true and your life will be much easier. The errors that happen because of mismatches can be rather obtuse and return very few Google hits. Keep things simple, match the build and deploy environments, once that's mastered if there's a requirement outside that scope evaluate it then.]

There's many different ways to build and deploy an Elixir app, **many**. In fact, there's a whole page of [other resources](./docs/resources.md) with information on some of those ways. My biases are going to come out, so let me state a few right up front:

- While I've taken an incremental approach here, the goal is to completely automate it all with a CI process,
- To get to a CI process you need to seperate you dev environment from your build/test/production environments
- Having spent a few years in the computer security world, I'm not a fan of installing build tools on production environments, so our process will be to install the build tools only in the build environment and deploy prebuilt binaries and assets to production
- This means a seperation of dev from build and build from production
- Containers give us a direct way to match our build environment to our production one

## Build
[Part 1: Distilling with Docker](./docs/distill_with_docker.md)

Part 2: Dockerfiles

## Run
Part 3: Bottling the Release with Docker

## But what about...

See the page of [resources](./docs/resources.md)

