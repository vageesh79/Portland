#!/bin/bash

docker run -d \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    --name=bifrost \
    --network=macvlan0 \
    --ip="$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).69" \
    --hostname=bifrost \
    --restart="unless-stopped" \
    --mount type=volume,source=bifrost-volume,target=/config \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime:ro \
    linuxserver/openvpn-as:latest
