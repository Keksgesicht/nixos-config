#!/bin/bash

work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

${work_dir}/relink-virtual-audio-devices.sh

### mute all hardware (laptop/mobile)
if [ "$(cat /etc/hostname)" = "cookiethinker" ]; then
	for alsa_dev in $(pactl list sinks short | awk '/alsa/ {print $2}'); do
		pactl set-sink-mute ${alsa_dev} 1
	done
fi

echo "Audio connection setup finished!"

if [ "$(cat /etc/hostname)" = "cookieclicker" ]; then
	sleep 2s
	systemctl --user --no-block restart flatpak-ferdium.service
fi
