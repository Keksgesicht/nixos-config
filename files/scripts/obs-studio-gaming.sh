EXEC_FILE="$0"
EXEC_MODE="$1"
user_id=$(id -u)

include_filter="mnt[\/]ram[\/]games|org.prismlauncher.PrismLauncher|[\/]WinePrefixes[\/]"
exclude_filter="Battle\.net|dolphin|d3ddriverquery64.exe|fossilize_replay|grep|konsole|legendary install"

run_stop() {
	nohup bash -c "${EXEC_FILE} stop 2>&1 | logger -t obs-studio-gaming.stopper" >/dev/null &
	disown
}

check_games_running() {
	check_obs

	games_text=$(ps -u ${user_id} -o cmd -w | grep -E "${include_filter}" | grep -Ev "${exclude_filter}")
	games_count=$(echo -n "${games_text}" | wc -l)

	# only the grep process?
	if [ ${games_count} -lt 1 ]; then
		return 1
	fi

#	echo ${games_text}
#	echo ${games_count}

	return 0
}

check_obs() {
	if [ "${EXEC_MODE}" == "start" ] && pidof obs >/dev/null; then
		echo "OBS Studio is already running"
		exit 0
	elif [ "${EXEC_MODE}" == "stop" ] && ! pidof obs >/dev/null; then
		echo "OBS Studio is not running anymore running"
		exit 0
	fi
}

run_obs() {
	screen_res=$(xrandr | awk '/primary/ {print $4}')
	echo "Starting OBS Studio with ReplayBuffer"

	run_stop

	if echo ${screen_res} | grep -q '3840x2160'; then
		echo "Recording 16:9 at 3840x2160"
		flatpak run \
			com.obsproject.Studio \
			--collection "Recording_16:9" \
			--profile "ShadowPlay_16:9" \
			--scene "Fullscreen" \
			--websocket_ipv4_only \
			--startreplaybuffer \
			--minimize-to-tray
	elif echo ${screen_res} | grep -q '3360x1440'; then
		echo "Recording 21:9 at 3360x1440"
		flatpak run \
			com.obsproject.Studio \
			--collection "Recording_21:9" \
			--profile "ShadowPlay_21:9" \
			--scene "Fullscreen" \
			--websocket_ipv4_only \
			--startreplaybuffer \
			--minimize-to-tray
	elif echo ${screen_res} | grep -q '5120x1440'; then
		echo "Recording 32:9 at 5120x1440"
		flatpak run \
			com.obsproject.Studio \
			--collection "Recording_32:9" \
			--profile "ShadowPlay_32:9" \
			--scene "Fullscreen" \
			--websocket_ipv4_only \
			--startreplaybuffer \
			--minimize-to-tray
	else
		echo "Recording 32:9 at 5120x1440"
		flatpak run \
			com.obsproject.Studio \
			--collection "Recording_32:9" \
			--profile "ShadowPlay_32:9" \
			--scene "Fullscreen" \
			--websocket_ipv4_only \
			--startreplaybuffer \
			--minimize-to-tray
	fi

	echo "OBS Studio exited with error code $?"
}

case ${EXEC_MODE} in
	"start")
		while ! check_games_running; do
			sleep 47s
		done
		run_obs
	;;
	"stop")
		sleep 13s
		while true; do
			while check_games_running; do
				sleep 69s
			done
			sleep 42s
			if ! check_games_running; then
				break
			fi
		done
		killall "obs"
	;;
esac
