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

If you're coming from a language like Ruby or Node there are a few differences in deploying an Elixir application. Each of these can cause problems on their own but are easy to work around.

1. there's going to be a compile phase (and possibly asset building too),
2. that compile/build is going to output an Erlang deployable, and
3. the build environment (OS and version) must **match** the deployment/production environment (OS and version). 

I don't cover installing [Docker](https://docs.docker.com/engine/installation/) or setting up [Distillery](https://github.com/bitwalker/distillery), there's a lot of good documentation there already.

[**Note:** Item #3 is probably going to cause some of you some heartburn because it's not absolutely 100% true. While there are some exceptions, treat it like it's completely true and your life will be much easier. The errors that happen because of mismatches can be rather obtuse and return very few Google hits. Keep things simple, match the build and deploy environments, once that's mastered if there's a requirement outside that scope evaluate it then.]

There are many different ways to build and deploy an Elixir app, **many**. In fact, there's a whole page of [other resources](./docs/resources.md) with information on some of those ways. My biases are going to come out, so let me state a few right up front:

- While I've taken an incremental approach here, the goal is to completely automate the whole thing with a CI process,
- To get to a CI process you need to separate you dev environment from your build/test/production environments
- Having spent a few years in the computer security world, I'm not a fan of installing build tools in production environments, so our process will be to install the build tools only in the build environment and deploy prebuilt binaries and assets to production
- This means a separation of dev from build and build from production
- Containers give us a direct way to match our build environment to our production one

## Distilling with Docker
[Part 1: A Good Begining](./docs/distill_with_docker_pt1.md)
[Part 2: Build it Faster](./docs/distill_with_docker_pt2.md)
[Part 3: Comments and Q&A](./docs/distill_with_docker_pt3.md)


## Bottling a Release

## Run

## But what about...

See the page of [resources](./docs/resources.md)

## Acknowledgements
While writing this I came across [Github - PagerDuty/docker_distiller]. There's lots of overlapping concepts between what I've done and their mix tasks. Effectively, I've explained the process a bit and they've automated it. They are a bit opinionated but I'm certainly interested where you could go with it. I particularly like the idea of doing a Dockerfile as an eex template.

[Releasing Elixir/OTP applications to the World](https://kennyballou.com/blog/2016/05/elixir-otp-releases/) Does an excellent job explaining the problem in detail.
[Lessons from Building a Node App in Docker](http://jdlm.info/articles/2016/03/06/lessons-building-node-app-docker.html)
[Github - Bitwalker's Phoenix Dockerfile](https://github.com/bitwalker/alpine-elixir-phoenix)