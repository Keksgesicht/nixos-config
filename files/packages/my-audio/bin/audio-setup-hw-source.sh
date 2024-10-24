#!/bin/bash

export work_dir=$(realpath $(dirname $0))
source ${work_dir}/../lib/settings.sh

unlink_inputs "${echo_in}"

hw_mic_list=$(pactl list sources short | grep -v monitor | awk '/alsa|bluez/ {print $2}')

### real mic?
hw_mic=""
for input_dev in ${my_mic_list}; do
	if echo "${hw_mic_list}" | grep -qE "^${input_dev}$"; then
		hw_mic=${input_dev}
		break
	fi
done

if [ -z "${hw_mic}" ]; then
	hw_mic=$(echo "${hw_mic_list}" | head -n 1)
fi

# only link if any device is present
if [ -n "${hw_mic}" ]; then
	link_nodes "${hw_mic}" "${echo_in}"
fi
