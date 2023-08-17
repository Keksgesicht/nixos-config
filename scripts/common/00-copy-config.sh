#!/usr/bin/env bash

CFG_DIR="$(realpath $(dirname $0)/../..)"

$AUTH rsync ${RSYNC_FLAGS} \
	-e "sudo -u keks ssh" \
	--rsync-path="sudo rsync" \
	${CFG_DIR}/ \
	${REMOTE_HOST}:nixos-config/
