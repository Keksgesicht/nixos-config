#!/usr/bin/env bash

rsync -avze ssh --delete \
	cookieclicker:git/hdd/nixos/config/ \
	~/git/hdd/nixos/config/ \
	--exclude='/secrets'

exit 0
