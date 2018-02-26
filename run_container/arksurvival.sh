#!/bin/bash
# https://hub.docker.com/r/plexinc/pms-docker/
# https://www.plex.tv/claim/

# Get Plex account claim token from user
read -rsp 'Admin Password: ' aPass
read -rsp 'Server Password: ' sPass

# Create Docker Volume
docker volume create ark

# Stand Up New container
docker run -d  \
  --name ark \
  --restart="unless-stopped" \
  --network=macvlan0 \
  --ip "$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).69" \
  --hostname ark \
  --mount type=volume,source=ark,target=/ark \
  -e SESSIONNAME=tpkark
  -e TZ="America/Denver" \
  boerngenschmidt/ark-docker
