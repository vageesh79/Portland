#!/bin/bash
# https://hub.docker.com/r/paulpoco/arch-delugevpn/

# get PIA credentials
read -pr 'Username for PIA: ' PIAUser
read -prs 'Password for PIA: ' PIAPass

# Stand Up new deluge container
docker run -d \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    --name=deluge \
    --network=macvlan0 \
    --ip="$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).64" \
    --hostname=deluge \
    --restart="unless-stopped" \
    --mount type=volume,source=deluge-volume,target=/config \
    --mount type=bind,source=/vpool/library/temp/.deluge,target=/data/temp \
    --mount type=bind,source=/vpool/library,target=/data/library \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_PROV=pia \
    -e VPN_USER="$PIAUser" \
    -e VPN_PASS="$PIAPass" \
    -e VPN_REMOTE="us-texas.privateinternetaccess.com" \
    -e VPN_PORT=1198 \
    -e VPN_PROTOCOL=udp \
    -e VPN_DEVICE_TYPE=tun \
    -e STRONG_CERTS=no \
    -e STRICT_PORT_FORWARD=yes \
    -e ENABLE_PRIVOXY=no \
    -e LAN_NETWORK="$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).0/24" \
    -e NAME_SERVERS="8.8.8.8,8.8.4.4" \
    -e DEBUG=false \
    -e UMASK=002 \
    -e PUID=6846 \
    -e PGID=6846 \
    paulpoco/arch-delugevpn:latest
