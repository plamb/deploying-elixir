# Deploying Elixir

I had some thoughts about deploying Elixir and decided to start putting them together. I like to start off small and see what grows. So there's a tiny sample plug app in lib, the content is in the docs directory, and the sample Dockerfiles are in docker. 

I do tend to be a bit opinionated but I'm constantly looking for better ideas, so if there's something that you don't like or think could be better, please open an issue and create a pull request.

**Disclaimer:** this isn't intended to be a set of guides where you copy/paste a complete deployment solution. It's a set of guides and ideas that you can implement as needed.

### Overview

Here's the overview of the process:

- Build our app using Distillery to create our release
- The build is going to happen inside a Docker container
- Deploy to a Docker container or VPS/Bare Metal Host

### Things you need to know

If you're coming from a language like Ruby or Node there's a few differences in deploying an Elixir application. Each of these can cause problems on their own but are quite easy to work around.

1. there's going to be a compile phase (and possibly asset building too),
2. that compile is going to output an Erlang deployable, and
3. the build environment (OS and version) must **match** the deployment environment (OS and version). 

I'm also not going to cover setting up Distillery, there's a lot of good documentation there already.

[**Note:** Item #3 is probably going to cause some of you some heartburn because it's not absolutely 100% true. Treat it like is and your life will be much easier. The errors that happen because of mismatches can be rather obtuse and return very few Google hits. Keep things simple, match the build and deploy environments, once that's mastered if there's a requirement outside that scope evaluate it then.]

## Build
[Part 1: Distilling with Docker](./docs/distill_with_docker.md)

Part 2: Dockerfiles

## Run
Part 3: Bottling the Release with Docker

## But what about...

There's a few other alternatives for this process. Probably the biggest being Heroku and edeliver. Links to more info on both are below. Because Heroku tends to be absolutely dead simple to setup, I won't spend much time on it.

(Heroku Links)
(Edeliver Links)

## Acknowledgements
(Distillery)
