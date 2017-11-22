#!/bin/bash
# https://hub.docker.com/r/dperson/samba/

# Stand-up new container
docker run -d \
  --name=samba \
  --network=bridge \
  -p 139:139 \
  -p 445:445 \
  --restart="unless-stopped" \
  -e TZ="America/Denver" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  --mount type=bind,source=/etc/shadow,target=/etc/shadow,readonly \
  --mount type=bind,source=/home,target=/home \
  --mount type=bind,source=/vpool/library,target=/data/library \
  --mount type=bind,source=/vpool/backups,target=/data/backups \
  dperson/samba

# Create smb.conf file
cat << EOF >> smb.conf
  [global]
  workgroup = WORKGROUP
  server string = Samba Server %v
  netbios name = portland
  security = user
  map to guest = bad user
  dns proxy = no

  [backups]
  path = /data/backups
  create mode = 770
  directory mode = 770
  #force user = wolfereign
  #force group = wolfereign
  browsable = yes
  writable = yes
  guest ok = no
  read only = no
  valid users = wolfereign

  [library]
  path = /data/library
  create mode = 770
  directory mode = 770
  force user = curator
  force group = curator
  browsable = yes
  writable = yes
  guest ok = no
  read only = no
  valid users = wolfereign
EOF

# Copy config file into container
docker cp smb.conf samba:/etc/samba/smb.conf

# Restart samba container
docker restart samba

# Cleanup
rm smb.conf
