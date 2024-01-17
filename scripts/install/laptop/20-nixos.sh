#!/usr/bin/env bash -x

# set to root of nixos-config
MY_NIX_CFG_DIR="$(realpath $(dirname $0)/../../..)"

# copy config over
copy-config() {
	mkdir -p ${1}
	rsync -rlpt --delete \
		--exclude=/.git \
		${MY_NIX_CFG_DIR}/ \
		${1}/
}
copy-config "/mnt/root/etc/nixos"
copy-config "/mnt/etc/nixos"

# setup nixos
nixos-install --root /mnt/root \
	--flake "${MY_NIX_CFG_DIR}"'#cookiethinker'

# install flatpak packages
nixos-enter --root /mnt/root \
	-c '/etc/nixos/scripts/laptop/21-flatpak.sh'

# finish system setup
mkpasswd > "/mnt/etc/nixos/secrets/keys/passwd/keks"
