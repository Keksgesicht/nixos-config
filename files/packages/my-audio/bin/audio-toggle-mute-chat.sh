#!/bin/bash

mute_state=$(pactl get-sink-mute 'chat_filter_sink' | awk '{print $2}')

if [ "${mute_state}" == "no" ]; then
	pactl set-sink-mute   'chat_filter_sink' 1
	pactl set-source-mute 'virt_mic_source'  1
else
	pactl set-sink-mute   'chat_filter_sink' 0
	pactl set-source-mute 'virt_mic_source'  0
fi
