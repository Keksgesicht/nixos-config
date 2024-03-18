#!/usr/bin/env bash

flatpak remote-add --if-not-exists \
	'flathub' \
	https://flathub.org/repo/flathub.flatpakrepo

# essential apps
flatpak install -y \
	com.github.tchx84.Flatseal

# nice to have
flatpak install -y \
	org.gnome.Firmware \
	org.kde.kclock
