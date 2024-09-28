#!/usr/bin/env bash

UMASK_DEF="022"
MNT="/mnt/nixos-install"
LUKS_NAME="nixos-install"

# create new GPT table
disk_gpt() {
	(
	echo g
	echo w
	) | fdisk "${DISK_TARGET}"
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
	sleep 1s
	echo w
	) | fdisk "${DISK_TARGET}"

	part_target=$(fdisk -l "${DISK_TARGET}" | grep "^${DISK_TARGET}" | awk '{print $1}')
	part_target_3=$(echo "${part_target}" | sed -n '3p')

	mkfs.vfat -F32 -n EFI -i "${UUID_EFI//-/}" "${part_target_3}"
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
	sleep 1s
	echo w
	) | fdisk "${DISK_TARGET}"

	part_target=$(fdisk -l "${DISK_TARGET}" | grep "^${DISK_TARGET}" | awk '{print $1}')
	part_target_1=$(echo "${part_target}" | sed -n '1p')
}

# format with LUKS and BTRFS on second partition
crypt_root() {
	umask 0177
	keyfile=$(mktemp)
	dd bs=512 count=4 iflag=fullblock if=/dev/urandom of="${keyfile}"
	umask ${UMASK_DEF}

	echo 'YES' | cryptsetup luksFormat "${part_target_1}" "${keyfile}"
	echo 'YES' | cryptsetup luksUUID "${part_target_1}" --uuid "${UUID_ROOT}"
	cryptsetup config "${part_target_1}" --label "${TARGET_HOSTNAME}-luks"

	cryptsetup open "${part_target_1}" ${LUKS_NAME} --key-file "${keyfile}"
	mkfs.btrfs -K -L "${TARGET_HOSTNAME}-data" "/dev/mapper/${LUKS_NAME}"

	# throw away keyfile
	# was only useful for automated setup process
	cryptsetup luksChangeKey "${part_target_1}" --key-file "${keyfile}"
	rm "${keyfile}"
}

setup_root() {
	mkdir -p "${MNT}"
	mount -o 'compress=zstd:3,subvol=/' \
		"/dev/mapper/${LUKS_NAME}" "${MNT}"
	pushd "${MNT}"

	btrfs subvolume create 'root'
	mkdir -p 'root/boot'
	mount "/dev/disk/by-uuid/${UUID_EFI}" 'root/boot'

	btrfs subvolume create 'etc'
	mkdir -p 'root/etc'
	mount -o 'compress=zstd:3,subvol=etc' \
		"/dev/mapper/${LUKS_NAME}" 'root/etc'

	btrfs subvolume create 'nix'
	mkdir -p 'root/nix'
	mount -o 'compress=zstd:3,subvol=nix' \
		"/dev/mapper/${LUKS_NAME}" 'root/nix'

	btrfs subvolume create 'home'
	btrfs subvolume create 'var'

		btrfs subvolume create 'mnt-array'
		pushd 'mnt-array'
		btrfs subvolume create 'homeBraunJan'
		popd

	popd
}


if mountpoint ${MNT}/root/boot \
|| mountpoint ${MNT}/root/etc \
|| mountpoint ${MNT}/root/nix \
|| mountpoint ${MNT} \
|| ls "/dev/mapper/${LUKS_NAME}"; then
	echo ""
	echo "###====================================###"
	echo "### umount or close action required!!! ###"
	echo "###====================================###"
	exit 1
fi

DISK_TARGET="$1"
UUID_EFI="$2"
UUID_ROOT="$3"
TARGET_HOSTNAME="$4"
usage() {
	echo "$0 [DISK] [UUID EFI] [UUID ROOT] [HOSTNAME]"
}

if ! [ -b "${DISK_TARGET}" ] \
|| [ -z "${UUID_EFI}" ] \
|| [ -z "${UUID_ROOT}" ] \
|| [ -z "${TARGET_HOSTNAME}" ]; then
	usage
	exit 2
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

# "4EFC-A800" "867c7b32-c672-4660-aa54-57262ff3ebdf" cookiepi
