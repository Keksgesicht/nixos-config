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
	mkdir -p 'backup_cache/name/root'
	ln -s '../backup_cache/name/root' 'root/.backup'

	btrfs subvolume create 'home'
	mkdir 'root/home'
	mount -o 'compress=zstd:3,subvol=home' \
		'/dev/mapper/target_root' 'root/home'
	mkdir -p 'backup_cache/name/home'
	ln -s '../backup_cache/name/home' 'home/.backup'

	btrfs subvolume create 'nix'
	mkdir 'root/nix'
	mount -o 'compress=zstd:3,subvol=nix' \
		'/dev/mapper/target_root' 'root/nix'

	btrfs subvolume create 'root/boot'
	mount '/dev/disk/by-uuid/90CE-7A63' 'root/boot'

	btrfs subvolume create 'appdata'
	mkdir -p 'backup_cache/name/appdata'
	ln -s '../backup_cache/name/appdata' 'appdata/.backup'

	btrfs subvolume create 'vm'
	mkdir -p 'backup_cache/name/vm'
	ln -s '../backup_cache/name/vm' 'vm/.backup'

	popd
}
