#!/bin/bash
# https://hub.docker.com/r/v2tec/watchtower/
# https://github.com/v2tec/watchtower

# Stand Up New container
docker run -d  \
  --name watchtower \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --interval=86400 \
  --cleanup \
  v2tec/watchtower:latest
