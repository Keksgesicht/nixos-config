#!/usr/bin/env bash

# set to root of nixos-config
MY_NIX_CFG_DIR="$(realpath $(dirname $0)/../..)"

RSYNC_FLAGS="-avzH --delete"
RSYNC_PATTERN_DIR="${MY_NIX_CFG_DIR}/scripts/rsync-pattern"

REMOTE_HOST="nixos-installer"
MY_HOME="/home/keks"
TARGET_MNT="/mnt/root"
TARGET_ARRAY_DIR="/mnt/mnt-array"


if ! [ -d ${MY_HOME} ]; then
	echo "Run this on an already configured host."
	exit 1
fi


set -x

$AUTH rsync ${RSYNC_FLAGS} \
	-e "sudo -u keks ssh" \
	--rsync-path="sudo rsync" \
	--include-from=${RSYNC_PATTERN_DIR}/NetworkManager \
	/etc/NetworkManager/system-connections/ \
	${REMOTE_HOST}:${TARGET_MNT}/etc/NetworkManager/system-connections/

rsync ${RSYNC_FLAGS} --delete-excluded \
	-e ssh \
	--include-from=${RSYNC_PATTERN_DIR}/home-keks \
	${MY_HOME}/ \
	${REMOTE_HOST}:${TARGET_MNT}${MY_HOME}/

rsync ${RSYNC_FLAGS} \
	--exclude=/backup \
	${MY_HOME}/Documents/development/containers/ \
	${REMOTE_HOST}:${TARGET_ARRAY_DIR}/homeBraunJan/Documents/development/containers/

# development directories (Studium)
rsync ${RSYNC_FLAGS} \
	--include-from="${RSYNC_PATTERN_DIR}/git-Studium" \
	${MY_HOME}/Documents/development/git/Studium/ \
	${REMOTE_HOST}:${TARGET_ARRAY_DIR}/homeBraunJan/Documents/development/git/Studium/

# TODO: unnecessary (convert to nix config)
rsync ${RSYNC_FLAGS} \
	-e "sudo -u keks ssh" \
	--rsync-path="sudo rsync" \
	/etc/unCookie/ \
	${REMOTE_HOST}:${TARGET_MNT}/etc/unCookie/

set +x
