#!/bin/bash

cfg_dir=$(realpath "$(dirname "$0")/../cfg/rsync.pattern")
system_name=$1
target_host=$2

TARGET_DIR="/mnt/array/machines"
DATA_DIR="${TARGET_DIR}/${system_name}"

rsync -avHA \
	-e "ssh -i /root/.secrets/ssh/id_backup" \
	--delete --delete-excluded \
	--include-from="${cfg_dir}/${system_name}" \
	"root@${target_host}":/ \
	"${DATA_DIR}"/
