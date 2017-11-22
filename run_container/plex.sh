#!/bin/bash
# https://hub.docker.com/r/plexinc/pms-docker/
# https://www.plex.tv/claim/

# Get Plex account claim token from user
read -prs 'Claim Token For Plex Account: ' CToken

# Stand Up New container
docker run -d  \
  --name plex \
  --restart="unless-stopped" \
  --device /dev/dri:/dev/dri \
  --network=macvlan0 \
  --ip "$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).60" \
  --hostname plex \
  --mount type=volume,source=plex-volume,target=/config \
  --mount type=tmpfs,target=/transcode,tmpfs-mode=1777 \
  --mount type=bind,source=/vpool/library/videos,target=/data \
  -e TZ="America/Denver" \
  -e PLEX_CLAIM="$CToken" \
  -e PLEX_UID="6846" \
  -e PLEX_GID="6846" \
  plexinc/pms-docker:plexpass

# Install WebTools Plugin For plex
## Create Script to pass to container
docker exec plex bash -c " \
  apt update; \
  apt install -y unzip wget; \
  wget https://github.com/$(wget https://github.com/ukdtom/WebTools.bundle/releases/latest -O - | grep -e '/.*/.*/.*zip' -o); \
  unzip WebTools.bundle.zip; \
  mv WebTools.bundle /config/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/; \
  chown -R plex:plex /config/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/WebTools.bundle"
