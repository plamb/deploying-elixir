## What's the target?

I'm going to make the assumption that you are deploying to some form of Linux. You need get specific on your deployment environment, as this will inform your decisions on the build environment.

- OS Distribution (Debian, Ubuntu, CentOs, RHEL, Fedora, Alpine, Arch...)
- OS Version (14.04, 16.04, Jessie, 7...)

You need to make sure our OS architect, version and Erlang dependencies **MATCH** in both our build container and our deployment environment. I can't put enou