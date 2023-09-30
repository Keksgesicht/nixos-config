#!/bin/bash

today=$(date +%Y-%m-%d)
new_time=$(date -u +%s -d "$today")
source $(dirname $0)/btrfs-snapshot

if ls ${dest} | grep -Eq "${today}_[dmw]"; then
	echo "backup_${mnt} already done for this day"
	exit 0
fi

# backup (readonly btrfs snapshot)
# backup naming (daily/weekly/monthly)
last_monthly=$(ls -1 $dest | grep '_m$' | tail -1)
last_weekly=$(ls -1 $dest | grep '_w$' | tail -1)
if ( [ -n "$monthly" ] && [ 0 -lt $monthly ] ) && ( [ -z "$last_monthly" ] || [ `time_diff $last_monthly` -ge 30 ] ); then
	day="${today}_m"
elif ( [ -n "$weekly" ] && [ 0 -lt $weekly ] ) && ( [ -z "$last_weekly" ] || [ `time_diff $last_weekly` -ge 7 ] ); then
	day="${today}_w"
else
	day="${today}_d"
fi
mkdir -v "${dest}/${day}"

# create snapshots and links
for dir in $shares; do
	btrfs subvolume show "$source/$dir/" >/dev/null || continue
	btrfs subvolume snapshot -r "$source/$dir" "$dest/$day/$dir"
	ln -srv "$dest/$day/$dir" "$backup/name/$dir/$day"
	rm -v "$backup/name/$dir/latest"
	ln -srv "$backup/name/$dir/$day" "$backup/name/$dir/latest"
done

# collect removeable backups
for file in $(ls ${dest} | sort -r); do
	case $(echo "${file}" | rev | cut -c 1) in
	"d") # daily
		daily=$(( ${daily} - 1 ))
		[ ${daily} -lt 0 ] || continue
		delete ${file}
	;;
	"w") # weekly
		weekly=$(( ${weekly} - 1 ))
		[ ${weekly} -lt 0 ] || continue
		delete ${file}
	;;
	"m") # monthly
		monthly=$(( ${monthly} - 1 ))
		[ ${monthly} -lt 0 ] || continue
		delete ${file}
	;;
	esac
done

exit 0
