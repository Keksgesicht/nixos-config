#!/run/current-system/sw/bin/bash -x

# set to root of nixos-config
MY_NIX_CFG_DIR="$(realpath $(dirname $0)/../..)"

# copy config over
mkdir -p /mnt/root/etc/nixos
rsync -rlpt --delete \
	--exclude=/.git \
	--exclude=/configuration.nix \
	${MY_NIX_CFG_DIR}/ \
	/mnt/root/etc/nixos/

# symlink config for laptop
pushd /mnt/root/etc/nixos
ln -srf configuration-cookiethinker.nix configuration.nix
popd

# setup nixos
nixos-install --root /mnt/root

# install flatpak packages
nixos-enter --root /mnt/root -c '/etc/nixos/scripts/laptop/21-flatpak.sh'

# finish system setup
nixos-enter --root /mnt/root -c 'passwd keks'
