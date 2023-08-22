#!/usr/bin/env bash

rsync -avze ssh --delete cookieclicker:git/nixos/config/ ~/git/nixos/config/ --exclude=/secrets

exit 0
