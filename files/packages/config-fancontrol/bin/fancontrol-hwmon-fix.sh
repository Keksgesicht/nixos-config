#!/usr/bin/env bash

set -e

find-hwmon() {
	find "$1" -mindepth 1 -maxdepth 1 | tr '/' '\n' | tail -1
}

file_input="$(dirname "$0")/../cfg/fancontrol.config.sample"
file_output="/etc/fancontrol"
cp "${file_input}" ${file_output}

hwmon_temp1=$(find-hwmon /sys/devices/pci0000:00/0000:00:18.3/hwmon)
hwmon_fan1=$(find-hwmon /sys/devices/platform/nct6775.656/hwmon)

sed -i 's|hwmon_temp1|'"${hwmon_temp1}"'|g' ${file_output}
sed -i  's|hwmon_fan1|'"${hwmon_fan1}"'|g'  ${file_output}
