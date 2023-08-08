#!/usr/bin/env bash

swapfile="/mnt/swap/file"
swapsize="16"

# DO NOT SNAPSHOT swapfile
$AUTH btrfs subvolume create $(dirname ${swapfile})

# cleanup old data
#$AUTH dd if=/dev/urandom of=${swapfile} bs=1G count=${swapsize}
$AUTH rm -f ${swapfile}

# create and mount swapfile
$AUTH btrfs filesystem mkswapfile -s ${swapsize}G ${swapfile}
$AUTH swapon ${swapfile}
