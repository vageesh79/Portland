#!/bin/bash
# https://hub.docker.com/r/plexinc/pms-docker/
# https://www.plex.tv/claim/

# Get Plex account claim token from user
read -rsp 'Claim Token For Plex Account: ' CToken

# Stand Up New container
docker run -d  \
  --name plex \
  --restart="unless-stopped" \
  --device /dev/dri:/dev/dri \
  --network=macvlan0 \
  --ip "$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).60" \
  --hostname plex \
  --mount type=bind,source=/vpool/docker-configs/plex,target=/config \
  --mount type=tmpfs,target=/transcode,tmpfs-mode=1777 \
  --mount type=bind,source=/vpool/library/videos,target=/data \
  -e TZ="America/Denver" \
  -e PLEX_CLAIM="$CToken" \
  -e PLEX_UID="6846" \
  -e PLEX_GID="6846" \
  plexinc/pms-docker:plexpass

# Pause and Give Plex Container Time to download and start web interface
 sleep 2m;

# Install WebTools Plugin For plex
## Create Script to pass to container
docker exec plex bash -c " \
  cd /root; \
  apt update; \
  apt install -y unzip wget curl; \
  wget https://github.com/$(wget https://github.com/ukdtom/WebTools.bundle/releases/latest -O - | grep -e '/.*/.*/.*zip' -o); \
  unzip WebTools.bundle.zip; \
  rm -R '/config/Library/Application Support/Plex Media Server/Plug-ins/WebTools.bundle'; \
  mv WebTools.bundle '/config/Library/Application Support/Plex Media Server/Plug-ins'); \
  chown -R plex:plex '/config/Library/Application Support/Plex Media Server/Plug-ins/WebTools.bundle'; \
  rm -R WebTools.bundle.zip"
