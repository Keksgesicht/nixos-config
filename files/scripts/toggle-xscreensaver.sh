#!/usr/bin/env bash

if systemctl --user is-active xscreensaver.service; then
	systemctl --user stop xscreensaver.service
else
	systemctl --user start xscreensaver.service
fi
