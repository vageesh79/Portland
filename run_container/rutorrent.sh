#!/bin/bash
# https://hub.docker.com/r/diameter/rtorrent-rutorrent/

# get PIA credentials
#read -pr 'Username for PIA: ' PIAUser
#read -prs 'Password for PIA: ' PIAPass

# Get WebUI Password
read -rp 'User for WebUI' WebUser
read -rsp 'Password for WebUI' WebPass

# Stand Up new rutorrent container
docker run -d \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    --name=rutorrent \
    --network=macvlan0 \
    --ip="$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).67" \
    --hostname=rutorrent \
    --restart="unless-stopped" \
    --mount type=volume,source=rutorrent-volume,target=/config \
    --mount type=bind,source=/vpool/library/temp/.rutorrent/downloads,target=/downloads \
    --mount type=bind,source=/vpool/library,target=/library \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime:ro \
    -e PHP_MEM=1024M \
    -e NOIPV6=1 \
    -e USR_ID=6846 \
    -e GRP_ID=6846 \
    diameter/rtorrent-rutorrent:stable

touch .htpasswd
echo "$WebUser:$(openssl passwd -crypt "$WebPass")" >> .htpasswd
docker cp .htpasswd rutorrent:/downloads/.htpasswd
rm .htpasswd
