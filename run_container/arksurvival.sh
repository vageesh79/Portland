#!/bin/bash
# https://github.com/boerngen-schmidt/Ark-docker

# Get Plex account claim token from user
read -rsp 'Admin Password: ' aPass
read -rsp 'Server Password: ' sPass

# Create Docker Volume
docker volume create ark

# Stand Up New container
docker run -it  \
  --name ark \
  --restart="unless-stopped" \
  --network=macvlan0 \
  --ip "$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).69" \
  --hostname ark \
  --mount type=bind,source=/vpool/docker-configs/ark,target=/ark \
  -e SESSIONNAME=TPK \
  -e SERVERMAP=TheIsland \
  -e SERVERPASSWORD=$sPass \
  -e ADMINPASSWORD=$aPass \
  -e MAX_PLAYERS=25 \
  -e TZ="America/Denver" \
  -e ARK_UID=4346 \
  -e ARK_GID=4346 \
  boerngenschmidt/ark-docker
