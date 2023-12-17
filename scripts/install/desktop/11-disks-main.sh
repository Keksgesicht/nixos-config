#!/run/current-system/sw/bin/bash

mount_raid_main() {
	mkdir -p '/mnt/main'
	mount -o 'compress=zstd:3,subvol=/' \
		'/dev/disk/by-label/main' '/mnt/main'
}

setup_raid_main() {
	pushd '/mnt/main'
	mkdir -p 'backup_main/date'
	mkdir -p 'backup_main/name'

	btrfs subvolume create 'mnt'
	mkdir -p 'mnt/main'

	btrfs subvolume create 'root'
	mkdir -p 'root/boot'
	mount '/dev/disk/by-uuid/F6A6-57AC' 'root/boot'

	btrfs subvolume create 'etc'
	mkdir -p 'root/etc'
	ln -s '../backup_main/name/etc' 'etc/.backup'

	btrfs subvolume create 'home'
	mkdir -p 'root/home'
	mount -o 'compress=zstd:3,subvol=home' \
		'/dev/disk/by-label/main' 'root/home'
	ln -s '../backup_main/name/home' 'home/.backup'

	btrfs subvolume create 'nix'
	mkdir -p 'root/nix'
	mount -o 'compress=zstd:3,subvol=nix' \
		'/dev/disk/by-label/main' 'root/nix'

	btrfs subvolume create 'var'
	mkdir -p 'root/var'
	mount -o 'compress=zstd:3,subvol=var' \
		'/dev/disk/by-label/main' 'root/var'

	btrfs subvolume create 'appdata'
	ln -s '../backup_main/name/appdata' 'appdata/.backup'

	btrfs subvolume create 'vm'
	ln -s '../backup_main/name/vm' 'vm/.backup'

	popd
}
