#!/bin/bash

export work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

${work_dir}/audio-relink-virtual-devices.sh

### mute mic feedback sink
pactl set-source-mute "feedback_source" 1

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

# react on new devices being added and connect them automatically
${work_dir}/../lib/audio-auto-relink.sh 'sink' &
pids[1]=$!
${work_dir}/../lib/audio-auto-relink.sh 'source' &
pids[2]=$!
for pid in ${pids[*]}; do
    wait $pid
done

exit 1
