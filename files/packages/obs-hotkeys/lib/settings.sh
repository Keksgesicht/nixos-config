#!/bin/bash

obs_cfg_path=".var/app/OBS-Studio/.config/obs-studio/plugin_config/obs-websocket/config.json"

obs_socket_host='127.0.0.1'
obs_socket_port='4455'
obs_socket_pass=$(jq -r '.server_password' "${HOME}/${obs_cfg_path}")

if [ -z "${obs_socket_pass}" ]; then
	echo "No server password!" >&2
	exit 2
fi

obs_cli() {
	obs-cli \
		--host ${obs_socket_host} \
		--port ${obs_socket_port} \
		--password "${obs_socket_pass}" \
		"$@"
}
