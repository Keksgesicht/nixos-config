#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "no version specified"
	exit 1
fi

MY_NIX_VER="$1"

if [ "$1" = "unstable" ]; then
	$AUTH nix-channel --add https://nixos.org/channels/nixos-${MY_NIX_VER} 'nixos'
	$AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz 'home-manager'
else
	$AUTH nix-channel --add https://nixos.org/channels/nixos-${MY_NIX_VER} 'nixos'
	$AUTH nix-channel --add https://github.com/nix-community/home-manager/archive/release-${MY_NIX_VER}.tar.gz 'home-manager'
fi

$AUTH nix-channel --list
$AUTH nix-channel --update
