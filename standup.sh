# System configuration for my home server (run as root)(Ubuntu Server)
# Zero to Operational

# Install options/roles should be UEFI, Standard System Utilities, OpenSSH Server

# get SSH credentials
read -p 'Username for SSH: ' sshUser
read -p 'Public Key for SSH: ' sshPubKey

# Run updates
apt update -y
apt upgrade -y

# Install ZFS and Impot zpool(vpool)
apt install -y zfsutils-linux
zpool import vpool

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
echo "[Service]" >> /etc/systemd/system/docker.service.d/docker.conf
echo "ExecStart=" >> /etc/systemd/system/docker.service.d/docker.conf
echo "ExecStart=/usr/bin/dockerd --graph="/vpool/docker" --storage-driver=zfs" >> /etc/systemd/system/docker.service.d/docker.conf
systemctl daemon-reload
systemctl start docker

# Setup Docker MacVLan (add ipv6 later)
docker network create -d macvlan  \
    --subnet=$(ip route get 8.8.8.8 | cut -d ' ' -f 3 | cut -d '.' -f 1-3).0/24  \
    --gateway=$(ip route get 8.8.8.8 | cut -d ' ' -f 3)  \
    -o parent=$(ip route get 8.8.8.8 | cut -d ' ' -f 5 | head -1) macvlan0

# Create Docker Management Group and Add User
groupadd docker
usermod -aG docker wolfereign

# Create media library user (curator)
useradd -u 6846 curator
echo curator:$(openssl rand -base64 32) | chpasswd
usermod -aG curator wolfereign

# Fix permissions on Library SubVolume
chown -R curator:curator /vpool/library
chmod -R 770 /vpool/library
chmod -R g+s /vpool/library

# Setup/Run Plex Docker Container

# Setup/Run Deluge Docker Container

# Setup/Run Samba Docker Container

# Setup/Run SMTP Mail Server Docker Container

# Setup ZFS Notifications
#mail relay
#user input for smtp password
#zfs notification service

# Setup SSH for main user
mkdir /home/$sshUser/.ssh
touch /home/$sshUser/.ssh/authorized_keys
chown -R $sshUser:$sshUser /home/$sshUser/.ssh
chmod 700 /home/$sshUser/.ssh
chmod 600 /home/$sshUser/.ssh/authorized_keys
cat $sshPubKey >> /home/$sshUser/.ssh/authorized_keys

# Change SSH Settings
sed -i  'Port 22/ c\Port 8668' /etc/ssh/sshd_config
sed -i  'PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
sed -i  'PubkeyAuthentication/ c\PubkeyAuthentication yes' /etc/ssh/sshd_config
sed -i  'AuthorizedKeysFile/ c\AuthorizedKeysFile %h/.ssh/authorized_keys' /etc/ssh/sshd_config
sed -i  'PasswordAuthentication/ c\PasswordAuthentication no' /etc/ssh/sshd_config
systemctl restart sshd

# Install Cockpit Web Gui
apt install -y cockpit cockpit-networkmanager cockpit-storaged cockpit-system cockpit-packagekit cockpit-docker