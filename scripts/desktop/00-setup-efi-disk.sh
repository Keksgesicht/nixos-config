#!/usr/bin/env bash

DISK_LABEL="EFI0"
DISK_UUID="F6A657AC"
DISK_FILE="/dev/nvme1n1p2"

$AUTH mkfs.vfat -F32 -n ${DISK_LABEL} -i ${DISK_UUID} ${DISK_FILE}
