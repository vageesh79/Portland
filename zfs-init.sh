#!/bin/bash

# System configuration for my home server (run as root)(Ubuntu Server)
# Create ZFS pool from scratch and create desired subvolumes/directories

# Refresh Repos
apt update -y

# Install ZFS
apt install -y zfsutils-linux

# List hard drives and partitions
lblsk

# Get ZFS Options
read -p 'ZFS - Specify desired pool name: ' RName
read -p 'ZFS - Specify raid type (raidz, raidz2, etc..): ' RType
read -p 'ZFS - Specify drives to add to raid (EX: /dev/sdb /dev/sdc /dev/sda): ' RDevices

# Create ZFS Raid
zpool

# Create ZFS Subvolumes and Additional Directories
zfs create $RName/docker
zfs create $RName/kvm
zfs create $RName/library
zfs create $RName/backups
mkdir /$RName/library/videos
mkdir /$RName/library/videos/tv_series
mkdir /$RName/library/videos/movies
mkdir /$RName/library/music
mkdir /$RName/library/books
mkdir /$RName/library/comics
mkdir /$RName/library/temp
mkdir /$RName/library/temp/.incomplete_torrents
