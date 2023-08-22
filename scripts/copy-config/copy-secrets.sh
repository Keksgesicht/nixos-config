#!/usr/bin/env bash

ssh cookieclicker sudo -S tar -C /home/keks/git/nixos/config/secrets -cf - -zstd . | sudo tar -xf - --zstd

exit 0
