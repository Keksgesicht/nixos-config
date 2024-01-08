#!/usr/bin/env bash

MY_HOME="/home/keks"
TARGET_MNT="/mnt/root"
TARGET_ARRAY_DIR="/mnt/mnt-array"


# homeBraunJan
mkdir -p ${TARGET_MNT}${MY_HOME}
chown 1000:1000 ${TARGET_MNT}${MY_HOME}

# Nextcloud Sync
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/BackUp/Upload2Cloud
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/Office
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Music/Alarms

# make sure these directories are owned by the user keks
chown -R 1000:1000 ${TARGET_ARRAY_DIR}/homeBraunJan
