#!/bin/bash

cfg_dir=$(realpath "$(dirname "$0")/../cfg")
system_name=$1
target_host=$2

TARGET_DIR="/mnt/array/machines"
DATA_DIR="${TARGET_DIR}/${system_name}"

download() {
	set -ex
	rsync -avHA \
		-e "ssh -i /root/.secrets/ssh/id_backup" \
		--delete --delete-excluded \
		"$@"
	set +ex
}

download-pattern() {
	download \
		--include-from="${cfg_dir}/rsync.pattern/${system_name}" \
		"root@${target_host}":/ \
		"${DATA_DIR}"/
}

download-snapshot() {
	while IFS="" read -r line; do
		mkdir -p "${DATA_DIR}${line}"
		download \
			"root@${target_host}":"${line}/.backup/latest/" \
			"${DATA_DIR}${line}/"
	done < "${cfg_dir}/snapshot/${system_name}"
}

realpath "${cfg_dir}"/*/"${system_name}"

if [ -f "${cfg_dir}/rsync.pattern/${system_name}" ]; then
	download-pattern
fi

if [ -f "${cfg_dir}/snapshot/${system_name}" ]; then
	download-snapshot
fi
