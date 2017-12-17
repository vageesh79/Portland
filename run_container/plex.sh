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

# Install WebTools Plugin For plex
pFolder="/vpool/docker-configs/plex/Library/Application Support/Plex Media Server/Plug-ins"

if [ ! -f "${pFolder}/WebTools.bundle" ]; then
    mkdir -p "${pFolder}/WebTools.bundle"
else
    rm -R "${pFolder}/WebTools.bundle"
fi

wget "$(curl -s https://api.github.com/repos/ukdtom/WebTools.bundle/releases/latest | grep browser_download_url | cut -d '"' -f 4)"
unzip WebTools.bundle.zip -d WebTools.bundle
mv WebTools.bundle "$pFolder"
chown -R curator:curator "$pFolder"
rm -R WebTools.bundle.zip
