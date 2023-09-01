#!/bin/bash

case $1 in
	sink)
		pactl subscribe | rg --line-buffered "Event 'new' on sink" | \
		while true; do
			read
			${work_dir}/audio-setup-hw-sink.sh
		done
	;;
	source)
		pactl subscribe | rg --line-buffered "Event 'new' on source" | \
		while true; do
			read
			${work_dir}/audio-setup-hw-source.sh
		done
	;;
esac
