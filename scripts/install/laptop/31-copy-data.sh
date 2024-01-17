#!/usr/bin/env bash

# set to root of nixos-config
MY_NIX_CFG_DIR="$(realpath $(dirname $0)/../..)"

RSYNC_FLAGS="-avzH --delete"
RSYNC_PATTERN_DIR="${MY_NIX_CFG_DIR}/scripts/rsync-pattern"

REMOTE_HOST="nixos-installer"
MY_HOME="/home/keks"
TARGET_MNT="/mnt"
TARGET_ARRAY_DIR="/mnt/mnt-array"


if ! [ -d ${MY_HOME} ]; then
	echo "Run this on an already configured host."
	exit 1
fi


set -x

rsync ${RSYNC_FLAGS} --delete-excluded \
	-e ssh \
	--include-from=${RSYNC_PATTERN_DIR}/home-keks \
	${MY_HOME}/ \
	${REMOTE_HOST}:${TARGET_MNT}${MY_HOME}/

set +x
