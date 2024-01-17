#!/usr/bin/env bash -x

# reduce screen brightness to 6,25%
echo 16 | sudo tee /sys/class/backlight/*/brightness >/dev/null

# get battery charge
bat_cap=$(cat /sys/class/power_supply/BAT0/capacity)
echo "Battery is at ${bat_cap}% charge."
