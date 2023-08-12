#!/usr/bin/env bash

# open luks partition
$AUTH cryptsetup open ${dpart} 'usb-backup'

# mount filesystems
$AUTH mount /mnt/backup/USB/data
$AUTH mount /dev/mapper/usb-backup /mnt/backup/USB/data
