#!/bin/bash

usage() {
	echo "usage: $0 [device name] [mode]"
	exit 1
}

if [ -z "$1" ]; then
	usage
fi
device_name="$1"

case "$2" in
"bind")
	mode="$2"
;;
"unbind")
	mode="$2"
;;
*)
	usage
;;
esac

if [ $(id -u) != 0 ]; then
	echo "please rerun as root!"
	exit 1
fi

usb_line=$(lsusb | grep "${device_name}" | head -n 1 | cut -d ':' -f1)
usb_id_vendor=$(echo ${usb_line} | cut -d ' ' -f2)
usb_id_device=$(echo ${usb_line} | cut -d ' ' -f4)

usb_id_vendor=$(( ${usb_id_vendor} ))
usb_id_device=$(( ${usb_id_device} - 1 ))

if ! echo ${usb_id_vendor}-${usb_id_device} | tee /sys/bus/usb/drivers/usb/${mode}; then
	echo ${usb_id_vendor}-${usb_id_device}
fi
