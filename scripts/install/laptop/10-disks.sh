#!/run/current-system/sw/bin/bash

UMASK_DEF="022"
UUID_EFI="90CE-7A63"
UUID_ROOT="c720b152-baf0-4336-bb04-83f01857cfab"
TARGET_HOSTNAME="cookiethinker"


# create new GPT table
disk_gpt() {
	(
	echo g
	echo w
	) | fdisk ${disk_target}
}

# create EFI partition
disk_efi() {
	(
	echo n
	echo 3
	echo
	echo
	echo t
	echo 3
	echo uefi
	echo w
	) | fdisk ${disk_target}

	part_target=$(fdisk -l ${disk_target} | grep "^${disk_target}" | awk '{print $1}')
	part_target_1=$(echo "${part_target}" | sed -n '1p')

	mkfs.vfat -F32 -n EFI -i ${UUID_EFI//-/} ${part_target_1}
}

# create root partition and 8G swap partition
disk_root_plus_swap() {
	(
	echo n
	echo 1
	echo 2048
	echo -9G
	echo n
	echo 2
	echo
	echo -1G
	echo t
	echo 2
	echo swap
	echo w
	) | fdisk ${disk_target}

	part_target=$(fdisk -l ${disk_target} | grep "^${disk_target}" | awk '{print $1}')
	part_target_2=$(echo "${part_target}" | sed -n '2p')
	part_target_3=$(echo "${part_target}" | sed -n '3p')
}

# format with LUKS and BTRFS on second partition
crypt_root() {
	umask 0177
	keyfile=$(mktemp)
	dd bs=512 count=4 iflag=fullblock if=/dev/urandom of=${keyfile}
	umask ${UMASK_DEF}

	echo 'YES' | cryptsetup luksFormat ${part_target_2} ${keyfile}
	echo 'YES' | cryptsetup luksUUID ${part_target_2} --uuid ${UUID_ROOT}
	cryptsetup config ${part_target_2} --label "${TARGET_HOSTNAME}-luks"

	cryptsetup open ${part_target_2} 'target_root' --key-file ${keyfile}
	mkfs.btrfs -K -L "${TARGET_HOSTNAME}-data" '/dev/mapper/target_root'

	# throw away keyfile
	# was only useful for automated setup process
	cryptsetup luksChangeKey ${part_target_2} --key-file ${keyfile}
	rm ${keyfile}
}

setup_root() {
	mount -o 'compress=zstd:3,subvol=/' \
		'/dev/mapper/target_root' '/mnt'
	pushd '/mnt'

	btrfs subvolume create 'mnt'
	mkdir -p 'mnt/cache'
	mkdir -p 'backup_cache/date'
	mkdir -p 'backup_cache/name'

	btrfs subvolume create 'root'
	mkdir -p 'root/boot'
	mount '/dev/disk/by-uuid/90CE-7A63' 'root/boot'

	btrfs subvolume create 'etc'
	mkdir -p 'root/etc'
	ln -s '../backup_cache/name/etc' 'etc/.backup'

	btrfs subvolume create 'home'
	mkdir 'root/home'
	mount -o 'compress=zstd:3,subvol=home' \
		'/dev/mapper/target_root' 'root/home'
	ln -s '../backup_cache/name/home' 'home/.backup'

	btrfs subvolume create 'nix'
	mkdir -p 'root/nix'
	mount -o 'compress=zstd:3,subvol=nix' \
		'/dev/mapper/target_root' 'root/nix'

	btrfs subvolume create 'var'
	mkdir -p 'root/var'
	mount -o 'compress=zstd:3,subvol=var' \
		'/dev/mapper/target_root' 'root/var'

		btrfs subvolume create 'mnt-array'
		mkdir -p 'mnt-array/backup_array/date'
		mkdir -p 'mnt-array/backup_array/name'

		pushd 'mnt-array'

		btrfs subvolume create 'homeBraunJan'
		ln -s '../backup_array/name/homeBraunJan' 'homeBraunJan/.backup'

		popd

	popd
}


if mountpoint /mnt/root/boot \
|| mountpoint /mnt/root/nix \
|| mountpoint /mnt \
|| ls '/dev/mapper/target_root'; then
	echo ""
	echo "###====================================###"
	echo "### umount or close action required!!! ###"
	echo "###====================================###"
	exit 1
fi


if [ -z "${disk_target}"]; then
	lsblk -f
	echo ""
	echo "Please set disk_target to your disk of choice!"
	echo "export disk_target=/dev/nvme0n1"
	echo "export disk_target=/dev/sda"
	exit 2
else
	echo "Using ${disk_target} for partitioning."
fi


# stop on any non-zero return
set -ex

disk_gpt
disk_root_plus_swap
disk_efi
crypt_root
setup_root

set +ex
lsblk -f
exit 0
