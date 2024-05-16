#!/usr/bin/env bash

MNT="/mnt/nixos-install"
LUKS_NAME="nixos-install"

if mountpoint ${MNT}/root/boot \
|| mountpoint ${MNT}/root/etc \
|| mountpoint ${MNT}/root/nix \
|| mountpoint ${MNT} \
|| test -b "/dev/mapper/${LUKS_NAME}"; then
	echo ""
	echo "###====================================###"
	echo "### umount or close action required!!! ###"
	echo "###====================================###"
	exit 1
fi

UUID_EFI="$1"
UUID_ROOT="$2"
usage() {
	echo "$0 [UUID EFI] [UUID ROOT]"
}

if [ -z "${UUID_EFI}" ] \
|| [ -z "${UUID_ROOT}" ]; then
	usage
	exit 2
fi

# stop on any non-zero return
set -ex

cryptsetup open "/dev/disk/by-uuid/${UUID_ROOT}" ${LUKS_NAME}

mkdir -p "${MNT}"
mount "/dev/mapper/${LUKS_NAME}" "${MNT}"

mount -o subvol=etc "/dev/mapper/${LUKS_NAME}" "${MNT}/root/etc"
mount -o subvol=nix "/dev/mapper/${LUKS_NAME}" "${MNT}/root/nix"
mount "/dev/disk/by-uuid/${UUID_EFI}" "${MNT}/root/boot"

set +ex

echo ""
ls -la -d "${MNT}/root/nix"
ls -la    "${MNT}/root/nix"
echo ""
ls -la -d "${MNT}/root/boot"
ls -la    "${MNT}/root/boot"
echo ""
ls -la -d "${MNT}"
ls -la    "${MNT}"

echo ""
echo nixos-install --show-trace --flake "$(realpath "$(dirname "$0")/../../..")"\'#\'hostname --root "${MNT}"/root

exit 0
