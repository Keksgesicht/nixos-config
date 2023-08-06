#!/run/current-system/sw/bin/bash

MY_HOME="/home/keks"
TARGET_MNT="/mnt/root"
TARGET_ARRAY_DIR="/mnt/mnt-array"


# homeBraunJan
mkdir -p ${TARGET_MNT}${MY_HOME}
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan
chown 1000:1000 ${TARGET_MNT}${MY_HOME}

# Locations
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Downloads
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Music
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Pictures
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Videos

# Pictures
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Pictures/Screenshots
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Pictures/background

# development and git
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/development/git
ln -sr ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/development/git \
       ${TARGET_ARRAY_DIR}/homeBraunJan/git
ln -sr ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/development \
       ${TARGET_ARRAY_DIR}/homeBraunJan/devel

# Studium
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/Studium
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/development/git/Studium

# Nextcloud Sync
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/BackUp/Upload2Cloud
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Documents/Office
mkdir -p ${TARGET_ARRAY_DIR}/homeBraunJan/Music/Alarms

# make sure these directories are owned by the user keks
chown -R 1000:1000 ${TARGET_ARRAY_DIR}/homeBraunJan
