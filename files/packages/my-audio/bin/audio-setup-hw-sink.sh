#!/bin/bash

export work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

### scatter to all hardware sinks
unlink_outputs 'echo_out_source'
for hard_dev in $(pactl list sinks short | awk '/alsa|bluez/ {print $2}'); do
	link_nodes 'echo_out_source' ${hard_dev}
done
