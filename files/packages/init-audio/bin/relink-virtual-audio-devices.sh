#!/bin/bash

work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

### scatter to all hardware sinks
unlink_outputs 'echo_out_source'
for hard_dev in $(pactl list sinks short | awk '/alsa|bluez/ {print $2}'); do
	link_nodes 'echo_out_source' ${hard_dev}
done

### loopback
link_nodes 'mic_loop_source' 'virt_mic_sink'
link_nodes 'mic_loop_source' 'echo_out_sink'

### filter to output
link_nodes 'media_filter_source' 'echo_out_sink'
link_nodes 'chat_filter_source' 'echo_out_sink'
link_nodes 'recording_out_source' 'echo_out_sink'


### unmute all outputs
if [ "$(cat /etc/hostname)" = "cookieclicker" ]; then
	for pulse_dev in $(pactl list sinks short | awk '{print $2}'); do
		pactl set-sink-mute ${pulse_dev} 0
	done
fi

### mute void sink
pactl set-sink-mute 'void_sink' 1

### mute GPU display output
for sink_hdmi in $(pactl list sinks short | awk '/hdmi/ {print $2}'); do
	pactl set-sink-mute "$sink_hdmi" 1
done


### real mic?
unlink_inputs 'echo_in_sink'
unlink_inputs 'mic_filter_sink'
link_nodes 'echo_in_source' 'mic_filter_sink'
link_nodes 'mic_filter_source' 'virt_mic_sink'

hw_mic_list=$(pactl list sources short | grep -v monitor | awk '/alsa|bluez/ {print $2}')
hw_mic=""
for input_dev in ${my_mic_list}; do
	if echo "${hw_mic_list}" | grep -qE "^${input_dev}$"; then
		hw_mic=${input_dev}
		break
	fi
done
if [ -z "$hw_mic" ]; then
	hw_mic=$(echo "${hw_mic_list}" | head -n 1)
fi
link_nodes ${hw_mic} 'echo_in_sink'


### set default devices
pactl set-default-source 'virt_mic_source'
pactl set-default-sink 'echo_out_sink'

### idk
unlink_inputs 'void_sink'

### VBAN for Gaming VM
#if [ -x ${work_dir}/vban-gaming.sh ]; then
#	${work_dir}/vban-gaming.sh
#fi
