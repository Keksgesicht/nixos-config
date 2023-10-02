#!/run/current-system/sw/bin/bash -x

# set to root of nixos-config
MY_NIX_CFG_DIR="$(realpath $(dirname $0)/../..)"
TARGET_DIR="/mnt/cache/root"

# copy config over
mkdir -p ${TARGET_DIR}/etc/nixos
rsync -rlpt --delete \
	--exclude=/.git \
	--exclude=/configuration.nix \
	${MY_NIX_CFG_DIR}/ \
	${TARGET_DIR}/etc/nixos/

# symlink config for laptop
pushd ${TARGET_DIR}/etc/nixos
ln -srf configuration-cookieclicker.nix configuration.nix
popd

# setup nixos
nixos-install --root ${TARGET_DIR}

# install flatpak packages
nixos-enter --root ${TARGET_DIR} -c '/etc/nixos/scripts/desktop/21-flatpak.sh'

# finish system setup
nixos-enter --root ${TARGET_DIR} -c 'passwd keks'
