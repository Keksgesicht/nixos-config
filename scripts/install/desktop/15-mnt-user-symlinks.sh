#!/usr/bin/env bash

mkdir -p mnt/user

ln -sv /mnt/cache/root mnt/user/root

ln -sv /mnt/cache/appdata  mnt/user/appdata
ln -sv /mnt/array/appdata2 mnt/user/appdata2
ln -sv /mnt/ram/appdata3   mnt/user/appdata3

ln -sv /mnt/array/backup_array mnt/user/backup_array
ln -sv /mnt/cache/backup_cache mnt/user/backup_cache

ln -sv /mnt/cache/home         mnt/user/home
ln -sv /mnt/array/homeBraunJan mnt/user/homeBraunJan
ln -sv /mnt/array/homeGaming   mnt/user/homeGaming

ln -sv /mnt/cache/vm  mnt/user/vm
ln -sv /mnt/array/vm2 mnt/user/vm2

ln -sv /mnt/cache/binWin    mnt/user/binWin
ln -sv /mnt/cache/system    mnt/user/system
ln -sv /mnt/array/resources mnt/user/resources
ln -sv /mnt/ram/games       mnt/user/games
