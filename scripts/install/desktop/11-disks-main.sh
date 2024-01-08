#!/usr/bin/env bash

mount_raid_main() {
	mkdir -p '/mnt/main'
	mount -o 'compress=zstd:3,subvol=/' \
		'/dev/disk/by-label/main' '/mnt/main'
}

setup_raid_main() {
	pushd '/mnt/main'

	btrfs subvolume create 'root'
	mkdir -p 'root/boot'
	mount '/dev/disk/by-uuid/F6A6-57AC' 'root/boot'

	btrfs subvolume create 'nix'
	mkdir -p 'root/nix'
	mount -o 'compress=zstd:3,subvol=nix' \
		'/dev/disk/by-label/main' 'root/nix'

	btrfs subvolume create 'etc'
	btrfs subvolume create 'home'
	btrfs subvolume create 'var'

	btrfs subvolume create 'appdata'
	btrfs subvolume create 'vm'

	popd
}
