#!/bin/bash

today=$(date +%Y-%m-%d-%H)
source $(dirname $0)/btrfs-snapshot

if ls ${dest} | grep -Eq "${today}_[h]"; then
	echo "backup_${mnt} already done for this hour"
	exit 0
fi

# backup (readonly btrfs snapshot)
# backup naming (hourly)
hour="${today}_h"
mkdir -v "${dest}/${hour}"

# create snapshots and links
for dir in $shares; do
	btrfs subvolume show "${source}/${dir}/" >/dev/null || continue
	btrfs subvolume snapshot -r "${source}/${dir}" "${dest}/${hour}/${dir}"
	ln -srv "${dest}/${hour}/${dir}" "${backup}/name/${dir}/${hour}"
#	rm -v "${backup}/name/${dir}/latest"
#	ln -srv "${backup}/name/${dir}/${hour}" "${backup}/name/${dir}/latest"
done

# collect removeable backups
for file in $(ls $dest | sort -r); do
	case $(echo "$file" | awk -F'_' '{print $NF}') in
	"h") # hourly
		hourly=$(( $hourly - 1 ))
		[ $hourly -lt 0 ] || continue
		delete $file
	;;
	esac
done

exit 0
