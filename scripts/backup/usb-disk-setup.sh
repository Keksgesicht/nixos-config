#!/usr/bin/env bash

# check disks
lsblk -f
dpart="/dev/sdi1"

# setup luks
$AUTH cryptsetup luksFormat ${dpart}

# set partition label
$AUTH cryptsetup config ${dpart} --label 'usb-backup-luks'

# open luks partition
$AUTH cryptsetup open ${dpart} 'usb-backup'

# create filesystem
$AUTH mkfs.btrfs -L 'usb-backup-data' /dev/mapper/usb-backup
