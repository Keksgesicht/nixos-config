#!/run/current-system/sw/bin/bash

mount_raid_array() {
	mkdir -p '/mnt/array'
	mount -o 'compress-force=zstd:3,subvol=/' \
		'/dev/disk/by-label/array' '/mnt/array'
}

setup_raid_array() {
	pushd '/mnt/array'
	mkdir -p 'backup_array/date'
	mkdir -p 'backup_array/name'

	btrfs subvolume create 'homeBraunJan'
	mkdir -p 'backup_array/name/homeBraunJan'
	ln -s '../backup_array/name/homeBraunJan' 'homeBraunJan/.backup'

	btrfs subvolume create 'homeGaming'
	mkdir -p 'backup_array/name/homeGaming'
	ln -s '../backup_array/name/homeGaming' 'homeGaming/.backup'

	btrfs subvolume create 'appdata2'
	mkdir -p 'backup_array/name/appdata2'
	ln -s '../backup_array/name/appdata2' 'appdata2/.backup'

	btrfs subvolume create 'resources'
	mkdir -p 'backup_array/name/resources'
	ln -s '../backup_array/name/resources' 'resources/.backup
	popd
}
