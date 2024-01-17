#!/usr/bin/env bash

# open luks partition
dev_path="/dev/disk/by-label/usb-backup-luks"
$AUTH cryptsetup open ${dev_path} 'usb-backup'

# mount filesystems
$AUTH mount /mnt/backup/USB/data
$AUTH mount /dev/mapper/usb-backup /mnt/backup/USB/data
