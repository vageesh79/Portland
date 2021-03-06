#!/bin/bash
# https://hub.docker.com/r/binhex/arch-delugevpn/

# get PIA credentials
read -rp 'Username for PIA: ' PIAUser
read -rsp 'Password for PIA: ' PIAPass

# get PIA openvpn config files and place the needed one in the proper directory
ccovpn="/vpool/docker-configs/deluge/openvpn" # Container's /config/openvpn
if [ ! -f "${ccovpn}/US Texas.ovpn" ]; then
    wget https://www.privateinternetaccess.com/openvpn/openvpn.zip
    unzip openvpn.zip -d openvpn
    rm -R "$ccovpn"
    mkdir -p "$ccovpn"
    mv "openvpn/US Texas.ovpn" "$ccovpn"
    mv openvpn/*.crt "$ccovpn"
    mv openvpn/*.pem "$ccovpn"
    chown -R curator:curator "$ccovpn"
    rm -R openvpn
    rm openvpn.zip
fi

# Stand Up new deluge container
docker run -d \
    --cap-add=NET_ADMIN \
    --name=deluge \
    --network=macvlan0 \
    --ip="$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).64" \
    --hostname=deluge \
    --restart="unless-stopped" \
    --mount type=bind,source=/vpool/docker-configs/deluge,target=/config \
    --mount type=bind,source=/vpool/library,target=/library \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_PROV=pia \
    -e VPN_USER="$PIAUser" \
    -e VPN_PASS="$PIAPass" \
    -e VPN_REMOTE="us-texas.privateinternetaccess.com" \
    -e STRICT_PORT_FORWARD=yes \
    -e ENABLE_PRIVOXY=no \
    -e LAN_NETWORK="$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).0/24" \
    -e NAME_SERVERS="8.8.8.8,8.8.4.4" \
    -e DEBUG=false \
    -e UMASK=002 \
    -e PUID=6846 \
    -e PGID=6846 \
    binhex/arch-delugevpn:latest
