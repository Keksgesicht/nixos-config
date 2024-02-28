#!/bin/bash -e

file_input="$(dirname $0)/../cfg/fancontrol.config.sample"
file_output="/etc/fancontrol"
cp ${file_input} ${file_output}

hwmon_temp1=$(ls /sys/devices/pci0000:00/0000:00:18.3/hwmon | head -n 1)
hwmon_fan1=$(ls /sys/devices/platform/nct6775.656/hwmon | head -n 1)

sed -i 's|hwmon_temp1|'${hwmon_temp1}'|g' ${file_output}
sed -i  's|hwmon_fan1|'${hwmon_fan1}'|g'  ${file_output}
