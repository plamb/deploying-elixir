# Distilling with Docker Part 3: Comments and Q&A

- Last updated: January 2017
- Elixir 1.4.0
- Distillery 1.1.0
- Docker 1.12

## Q & A

There's going to be some question and I'll try and answer a few right up front.

#### But...what about?
Yes, there's a couple of other ways we could have done the Dockerfile and the commands. Particularly, why didn't we just use another volume and map our source directory right into the container? Mostly, because I really, really want a separation between our dev, build, test and prod environments. I did not want any local dev bits getting into our build.

#### Why can't you do it all with the docker build command?
You can only mount volumes when running the `docker run` command. To get around this, we could have done a `RUN mix release` in the Dockerfile and then used a `docker cp` to copy the file out. But this means that the commands run on the container are hard coded into the container. Instead, we use a `CMD [bash]` to tell the container what to execute when a `docker run` is issued without any arguments, we then override that command with the final option `mix release --env=prod`. This gives us an easy way to specify options and commands to the container, i.e. `mix release.upgrade --env=prod`.

#### But I want to git clone the source into the container.
At some point, I might write that how-to, maybe. But I'd suggest you let that automagically happen with your CI system instead. In the meantime, you might take a look at [Building docker images with two Dockerfiles](http://blog.tomecek.net/post/build-docker-image-in-two-steps).

#### What about a Phoenix app?
Take a look at the highly untested [docker/Dockerfile.build.phoenix](./docker/Dockerfile.build.phoenix). There's a few more steps, including adding Nodejs for asset compilation.

#### What about environment variables?
Ugh...yeah...this can trip you up. An article just on this is "coming soon". I promise.

# See Also
[Distilling with Docker, Part 1: A Good Begining](./distill_with_docker_pt1.md)

[Distilling with Docker, Part 2: Build it Faster](./distill_with_docker_pt2.md)

[Distilling with Docker, Part 3: Comments and Q&A](./distill_with_docker_pt3.md)
