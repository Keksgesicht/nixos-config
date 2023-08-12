#!/bin/bash

### -------- ###
### lancache ###
### -------- ###

cd /mnt/cache/appdata/lancache/cache-domains/
git pull

cd scripts/
rm -r ./output/unbound/
bash ./create-unbound.sh

unbound_config_file="/mnt/cache/appdata/unbound/conf/lancache.conf"
truncate -s 0 ${unbound_config_file}.tmp
for game_service in $(ls ./output/unbound/*.conf); do
	echo "# "$(basename $game_service .conf) >> ${unbound_config_file}.tmp
	for dom in $(awk '/local-zone/ {print $2}' $game_service); do
		echo "  local-zone-override: ${dom} fd00:172:23::443:0/112 always_transparent" >> $game_service
		echo "  local-zone-override: ${dom} 172.23.80.0/24 always_transparent" >> $game_service
#		echo "  local-data: ${dom} 30 IN AAAA fd00:3581::192:168:178:150" >> $game_service
	done
	tail -n +2 $game_service | sort -uk2 >> ${unbound_config_file}.tmp
	echo "" >> ${unbound_config_file}.tmp
done
mv ${unbound_config_file}.tmp ${unbound_config_file}
