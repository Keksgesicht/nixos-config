#/usr/bin/env bash

# run all in the root dir of the target installation
if mountpoint -q "/mnt/cache/root"; then
	cd /mnt/cache/root
elif mountpoint -q "/mnt/root"; then
	cd /mnt/root
else
	exit 1
fi

# calendar does not show events without it
# https://github.com/NixOS/nixpkgs/issues/143272
# https://bugs.kde.org/show_bug.cgi?id=400451
# https://invent.kde.org/plasma/plasma-workspace/-/blob/4df78f841cc16a61d862b5b183e773e9f66436b8/ktimezoned/ktimezoned.cpp#L124
mkdir -p usr/share
ln -s /etc/zoneinfo usr/share/zoneinfo
