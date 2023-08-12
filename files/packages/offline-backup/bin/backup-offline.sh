#!/bin/bash

back_dir="/mnt/backup/$1"
conf_dir="/etc/unCookie/cfg/backup/offline"

sleep 3s
mountpoint ${back_dir}/data || exit 1
chown root:root ${back_dir}
chmod 700 ${back_dir}

for dir in $(cat ${conf_dir}/_shares); do
	sync_vars=""
	source="/mnt/user/${dir}/.backup/latest"
	dest="${back_dir}/data/${dir}"

	[ -f ${conf_dir}/${dir}.pattern ] && \
		sync_vars+=" --include-from=${conf_dir}/${dir}.pattern"

#	rsync -avcHAX --delete --delete-excluded ${sync_vars} ${source}/ ${dest}/
	rsync -avHAX --delete --delete-excluded ${sync_vars} ${source}/ ${dest}/

	touch ${dest}
	echo "${dir} completed"
done
