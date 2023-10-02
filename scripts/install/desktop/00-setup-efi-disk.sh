#!/usr/bin/env bash

DISK_LABEL="EFI0"
DISK_UUID="F6A657AC"
DISK_FILE="/dev/nvme1n1"

(
echo t
echo 2
echo uefi
echo w
) | fdisk ${DISK_FILE}

mkfs.vfat -F32 -n ${DISK_LABEL} -i ${DISK_UUID} "${DISK_FILE}p2"
