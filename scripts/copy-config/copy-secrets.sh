#!/usr/bin/env bash

sudo mkdir -p /tmp/secrets

ssh cookieclicker \
	sudo -S \
		tar -C /home/keks/git/hdd/nixos/config/secrets -cf - --zstd . | \
	sudo tar -C /tmp/secrets -xf - --zstd

sudo rsync -rlptv --delete \
	/tmp/secrets/ \
	~/git/hdd/nixos/config/secrets/

sudo rm -r /tmp/secrets

exit 0
