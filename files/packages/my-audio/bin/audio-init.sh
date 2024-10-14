#!/bin/bash

work_dir=$(realpath "$(dirname "$0")")
export work_dir
source "${work_dir}"/../lib/settings.sh


mute_hardware() {
	### mute all hardware (laptop/mobile)
	if [ "$(cat /etc/hostname)" = "cookiethinker" ]; then
		for alsa_dev in $(pactl list sinks short | awk '/alsa/ {print $2}'); do
			pactl set-sink-mute "${alsa_dev}" 1
		done
	fi

	### mute hdmi outputs on desktop
	if [ "$(cat /etc/hostname)" = "cookieclicker" ]; then
		for alsa_dev in $(pactl list sinks short | awk '/alsa_output.pci-0000_44_00.1.pro-output/ {print $2}'); do
			pactl set-sink-mute "${alsa_dev}" 1
		done
	fi
}


sleep 0.67s
mute_hardware

sleep 0.67s
mute_hardware
"${work_dir}"/audio-relink-virtual-devices.sh

### mute mic feedback sink
pactl set-source-mute "feedback_source" 1

sleep 0.42s
mute_hardware

echo "Audio connection setup finished!"

# react on new devices being added and connect them automatically
"${work_dir}"/../lib/audio-auto-relink.sh 'sink' &
pids[1]=$!
"${work_dir}"/../lib/audio-auto-relink.sh 'source' &
pids[2]=$!
for pid in "${pids[@]}"; do
    wait "$pid"
done

exit 1
