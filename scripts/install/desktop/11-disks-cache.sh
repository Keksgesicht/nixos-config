#!/run/current-system/sw/bin/bash

mount_raid_cache() {
	mkdir -p '/mnt/cache'
	mount -o 'compress=zstd:3,subvol=/' \
		'/dev/disk/by-label/cache' '/mnt/cache'
}

setup_raid_cache() {
	pushd '/mnt/cache'
	mkdir -p 'backup_cache/date'
	mkdir -p 'backup_cache/name'

	btrfs subvolume create 'mnt'
	mkdir -p 'mnt/cache'

	btrfs subvolume create 'root'
	mkdir -p 'root/boot'
	mount '/dev/disk/by-uuid/F6A6-57AC' 'root/boot'

	btrfs subvolume create 'etc'
	mkdir -p 'root/etc'
	ln -s '../backup_cache/name/etc' 'etc/.backup'

	btrfs subvolume create 'home'
	mkdir -p 'root/home'
	mount -o 'compress=zstd:3,subvol=home' \
		'/dev/disk/by-label/cache' 'root/home'
	ln -s '../backup_cache/name/home' 'home/.backup'

	btrfs subvolume create 'nix'
	mkdir -p 'root/nix'
	mount -o 'compress=zstd:3,subvol=nix' \
		'/dev/disk/by-label/cache' 'root/nix'

	btrfs subvolume create 'var'
	mkdir -p 'root/var'
	mount -o 'compress=zstd:3,subvol=var' \
		'/dev/disk/by-label/cache' 'root/var'

	btrfs subvolume create 'appdata'
	ln -s '../backup_cache/name/appdata' 'appdata/.backup'

	btrfs subvolume create 'vm'
	ln -s '../backup_cache/name/vm' 'vm/.backup'

	popd
}
