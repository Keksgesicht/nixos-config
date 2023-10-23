#!/bin/bash

OLDIFS=${IFS}


### only keep last 3 lines of DDNS log
if [ -d "/mnt/cache/appdata/ddns" ]; then
	ddns_file="/mnt/cache/appdata/ddns/v4/cf-ddns-updates.json"
	tail -n 3 ${ddns_file} | sponge ${ddns_file}
	ddns_file="/mnt/cache/appdata/ddns/v6/cf-ddns-updates.json"
	tail -n 3 ${ddns_file} | sponge ${ddns_file}
fi


### clear old cache files
find /home/*/.cache -type f -mtime +42 ! -name 'p10k*' ! -name 'gitstatus*' -delete
find /home/*/.cache -type d -empty -delete

### clear flatpak cache files
rm -r /home/*/.var/app/io.gitlab.librewolf-community/cache
rm -r /home/*/.var/app/org.kde.kdenlive/cache
rm -r /home/*/.var/app/org.mozilla.firefox/cache

### delete temporary flatpak overrides
### they are now managed by nix
### /var/lib/flatpak/overrides -> /etc/flatpak/overrides -> pkgs.flatpak-overrides
rm -fr /home/*/.local/share/flatpak/overrides

### delete old Tab Group backups
find /mnt/array/homeBraunJan/Downloads/STG-backups/ -type f -atime +2 -delete

### delete unnecessary screenshots
find /mnt/array/homeBraunJan/Pictures/Screenshots -type f -name 'Screenshot*' -atime +3 -delete


### cleanup /root directory
find /root/.cache -mindepth 1 -delete
find /root/.dbus  -mindepth 1 -delete
find /root/.local -mindepth 1 -delete


### LaTex
export LC_ALL='en_US.utf8'
tmp_file_endings="$(dirname $(realpath $0))/../cfg/LaTex"

tmp_file_dir=$(mktemp)
cat << 'EOF' > $tmp_file_dir
array/homeBraunJan/Documents/Studium/Module
array/homeBraunJan/Documents/Office/Finanzen/Freiberufler
array/homeBraunJan/Documents/development/git/Studium
EOF

IFS=$'\n'   # forloop separator - only newlines
for dir in $(cat $tmp_file_dir); do
	for file in $(plocate '*/'"${dir}"'/*/*.tex'); do
		texdir=$(dirname "${file}")
		cd "${texdir}"
		for end in $(cat $tmp_file_endings); do
			find "${texdir}" -maxdepth 1 -type f -name '*.'"${end}" -print -delete
		done
	done
done
IFS=${OLDIFS}
rm $tmp_file_dir


### only keep newest version of nextcloud or mobile phone backups
if [ -d "/mnt/array/appdata2/nextcloud" ]; then
	while ! systemctl is-active podman-nextcloud.service; do
		sleep 5s
	done
	sleep 10s

	##
	### Cleanup older Backups in Nextcloud
	##
	docexe-nextcloud() {
		podman exec -w /var/www/html -u www-data nextcloud $@
	}

	### limit Calendar Backups
	IFS=$'\n'
	for contact_group in $(find /mnt/array/appdata2/nextcloud/janb/files/.Calendar-Backup -type f -name '*.ics' | \
                           awk -F'_' '{for(i=1;i<=NF-2;i++) printf $i"_"; print ""}' | sort | uniq); do
		for contact_file in $(ls "${contact_group}"* | head -n -3); do
			rm "${contact_file}"
		done
	done
	IFS=${OLDIFS}
	docexe-nextcloud ./occ files:scan --path=/janb/files/.Calendar-Backup/ >/dev/null

	### limit Contact Backups
	find /mnt/array/appdata2/nextcloud/janb/files/.Contacts-Backup -type f -name '*.vcf' | \
		head -n -3 | xargs --no-run-if-empty /bin/rm -v
	docexe-nextcloud ./occ files:scan --path=/janb/files/.Contacts-Backup/ >/dev/null

	### limit Signal Chat Backups
	find /mnt/array/appdata2/nextcloud/janb/files/InstantUpload/SignalBackup -type f -name 'signal-*.backup' | \
		head -n -3 | xargs --no-run-if-empty /bin/rm -v
	docexe-nextcloud ./occ files:scan --path=/janb/files/InstantUpload/SignalBackup/ >/dev/null
fi
