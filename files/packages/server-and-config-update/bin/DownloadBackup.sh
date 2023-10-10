#!/bin/bash

work_dir="$(realpath $(dirname $0))"

# switch to backup directory
export TARGET_DIR="/mnt/array/homeBraunJan/Documents/BackUp"

# create backup from Hetzner Mail-Server
cd ${work_dir}/DownloadBackup/mailcow
./backup_mailcow.sh

# create backup from RaspberryPi
cd ${work_dir}/DownloadBackup/pihole
./backup_pihole.sh
