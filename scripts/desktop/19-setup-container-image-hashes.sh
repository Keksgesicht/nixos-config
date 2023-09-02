#!/usr/bin/env bash

mkdir -p etc/unCookie/containers/hashes

BACKUP_DIR="/mnt/backup/USB/data"

rsync -avHAX --delete \
	${BACKUP_DIR}/root/etc/unCookie/containers/hashes \
	etc/unCookie/containers/hashes/
