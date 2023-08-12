#!/bin/bash

# delete old backups (update will create these)
#rm -r /mnt/array/appdata2/nextcloud/updater-*/backups/*

# start update via cli
podman exec \
	-w /var/www/html \
	-u www-data \
	nextcloud \
	php updater/updater.phar --no-interaction --no-backup

# fix missing indices
podman exec \
	-w /var/www/html \
	-u www-data \
	nextcloud \
	./occ db:add-missing-indices
