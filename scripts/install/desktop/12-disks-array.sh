#!/usr/bin/env bash

mount_raid_array() {
	mkdir -p '/mnt/array'
	mount -o 'compress-force=zstd:3,subvol=/' \
		'/dev/disk/by-label/array' '/mnt/array'
}

setup_raid_array() {
	pushd '/mnt/array'

	btrfs subvolume create 'homeBraunJan'
	btrfs subvolume create 'homeGaming'
	btrfs subvolume create 'appdata2'
	btrfs subvolume create 'resources'

	popd
}
