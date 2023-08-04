#!/bin/bash

work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

relink-virtual-audio-devices.sh

### mute all hardware (laptop/mobile)
for alsa_dev in $(pactl list sinks short | awk '/alsa/ {print $2}'); do
	pactl set-sink-mute ${alsa_dev} 1
done

echo "Audio connection setup finished!"

sleep 2s
