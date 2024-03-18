#!/bin/bash

obs_cfg_path=".var/app/OBS-Studio/.config/obs-studio/global.ini"

obs_socket_host='127.0.0.1'
obs_socket_port='4444'
obs_socket_pass=$(awk -F'=' '/ServerPassword/ {print $2}' "${HOME}/${obs_cfg_path}")

obs_cli() {
	obs-cli \
		--host ${obs_socket_host} \
		--port ${obs_socket_port} \
		--password ${obs_socket_pass} \
		$@
}
