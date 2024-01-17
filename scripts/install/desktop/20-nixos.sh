#!/usr/bin/env bash -x

# set to root of nixos-config
MY_NIX_CFG_DIR="$(realpath $(dirname $0)/../../..)"
TARGET_DIR="/mnt/main/root"
PW_FILE="/etc/nixos/secrets/keys/passwd/keks"

# copy config over
copy-config() {
	mkdir -p ${1}
	rsync -rlpt --delete \
		--exclude=/.git \
		${MY_NIX_CFG_DIR}/ \
		${1}/
}
copy-config "${TARGET_DIR}/etc/nixos"
copy-config "$(dirname ${TARGET_DIR})/etc/nixos"

# setup nixos
nixos-install --root ${TARGET_DIR} \
	--flake "${MY_NIX_CFG_DIR}"'#cookieclicker'

# install flatpak packages
nixos-enter --root ${TARGET_DIR} \
	-c '/etc/nixos/scripts/desktop/21-flatpak.sh'

# finish system setup
mkpasswd > "$(dirname ${TARGET_DIR})${PW_FILE}"
