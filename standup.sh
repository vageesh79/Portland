#!/bin/bash

# System configuration for my home server (run as root)(Ubuntu Server)
# Zero to Operational

# Install options/roles should be UEFI, Standard System Utilities, OpenSSH Server

# get Username for primary User
read -pr 'Primary Username: ' user

# get SSH public key for primary user
read -prs 'Public Key for SSH: ' sshPubKey


# get SNMTP credentials
#read -pr 'SMTP User: ' smtpUser
#read -prs 'SMTP Password: ' smtpPass

# Run updates
apt update -y
apt upgrade -y

# Install ZFS and Impot zpool(vpool)
apt install -y zfsutils-linux
zpool import vpool

# Setup ZFS Notifications
#mail relay
#user input for smtp password
#zfs notification service

# Install Docker
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce
systemctl enable docker

# Create Docker Subvolume on zfs pool (will not overwrite if it already exists)
zfs create vpool/docker

# Change Dockers Storage to ZFS Pool
systemctl stop docker
mkdir /etc/systemd/system/docker.service.d
touch /etc/systemd/system/docker.service.d/docker.conf
cat << 'EOF' >> /etc/systemd/system/docker.service.d/docker.conf
    "[Service]"
    "ExecStart="
    "ExecStart=/usr/bin/dockerd --graph="/vpool/docker" --storage-driver=zfs"
EOF
systemctl daemon-reload
systemctl start docker

# Setup Docker MacVLan (add ipv6 later)
docker network create -d macvlan  \
    --subnet="$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).0/24"  \
    --gateway="$(ip route get 8.8.8.8 | cut -d ' ' -f 3)"  \
    -o parent="$(ip route get 8.8.8.8 | cut -d ' ' -f 5 | head -1)" macvlan0

# Create Docker Management Group and Add User
groupadd docker
usermod -aG docker "$user"

# Create media library user (curator)
useradd -u 6846 curator
echo curator:"$(openssl rand -base64 32)" | chpasswd
usermod -aG curator "$user"

# Fix permissions on Library SubVolume
chown -R curator:curator /vpool/library
chmod -R 770 /vpool/library
chmod -R g+s /vpool/library

# Setup SSH for main user
mkdir "/home/$user/.ssh"
touch "/home/$user/.ssh/authorized_keys"
chown -R "$user:$user /home/$user/.ssh"
chmod 700 "/home/$user/.ssh"
chmod 600 "/home/$user/.ssh/authorized_keys"
cat "$sshPubKey" >> "/home/$user/.ssh/authorized_keys"

# Change SSH Settings
sed -i  'Port 22/ c\Port 8668' /etc/ssh/sshd_config
sed -i  'PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
sed -i  'PubkeyAuthentication/ c\PubkeyAuthentication yes' /etc/ssh/sshd_config
sed -i  'AuthorizedKeysFile/ c\AuthorizedKeysFile %h/.ssh/authorized_keys' /etc/ssh/sshd_config
sed -i  'PasswordAuthentication/ c\PasswordAuthentication no' /etc/ssh/sshd_config
systemctl restart sshd

# Install Cockpit Web Gui
apt install -y cockpit cockpit-networkmanager cockpit-storaged cockpit-system cockpit-packagekit cockpit-docker
