#!/usr/bin/env bash

WORK_DIR=$(dirname "$(realpath "$0")")

# import shared config
source "${WORK_DIR}/../lib/settings.sh"

# send signal to save the ReplayBuffer to Disk
obs_cli 'replaybuffer' 'save'
