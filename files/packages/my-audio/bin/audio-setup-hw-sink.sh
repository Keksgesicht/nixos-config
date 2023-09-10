#!/bin/bash

export work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

unlink_outputs 'echo_out_source'

### scatter to all hardware sinks
for hard_dev in $(pactl list sinks short | awk '/alsa|bluez/ {print $2}'); do
	link_nodes 'echo_out_source' ${hard_dev}
done

unlink_outputs 'echo_in_sink'
