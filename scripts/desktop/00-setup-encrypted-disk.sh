#!/usr/bin/env bash

RAW_PART="/dev/nvme1n1p1"
RAW_LABEL="cache1"
KEY_FILE="/etc/unCookie/keys/luks-cache"

$AUTH cryptsetup luksFormat ${PART_RAW}
$AUTH cryptsetup config ${PART_RAW} --label ${RAW_LABEL}
$AUTH cryptsetup open ${PART_RAW} ${RAW_LABEL}
$AUTH cryptsetup luksAddKey ${PART_RAW} ${KEY_FILE}
