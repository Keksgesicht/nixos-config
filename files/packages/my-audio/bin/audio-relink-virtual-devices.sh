#!/bin/bash

export work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

${work_dir}/audio-setup-hw-sink.sh

### loopback
link_nodes 'mic_loop_source' 'virt_mic_sink'
link_nodes 'mic_loop_source' 'echo_out_sink'

### filter to output
link_nodes 'media_filter_source' 'echo_out_sink'
link_nodes 'chat_filter_source' 'echo_out_sink'
link_nodes 'recording_out_source' 'echo_out_sink'


### unmute all virtual outputs
for pulse_dev in $(pactl list sinks short | grep -vE 'alsa|bluez' | awk '{print $2}'); do
	pactl set-sink-mute ${pulse_dev} 0
done

### mute void sink
pactl set-sink-mute 'void_sink' 1

unlink_inputs 'mic_filter_sink'
link_nodes 'echo_in_source' 'mic_filter_sink'
link_nodes 'mic_filter_source' 'virt_mic_sink'
${work_dir}/audio-setup-hw-source.sh


### set default devices
pactl set-default-source 'virt_mic_source'
pactl set-default-sink 'echo_out_sink'

### idk
unlink_inputs 'void_sink'

### VBAN for Gaming VM
#if [ -x ${work_dir}/vban-gaming.sh ]; then
#	${work_dir}/vban-gaming.sh
#fi
