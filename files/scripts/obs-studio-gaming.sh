EXEC_FILE="$0"
EXEC_MODE="$1"
user_id=$(id -u)

game_dir=$(echo "${HOME}/Games" | sed -e 's|/|[\/]|g')
wine_dir=$(echo "${HOME}/WinePrefixes" | sed -e 's|/|[\/]|g')

include_filter="${game_dir}|${wine_dir}|PrismLauncher"
exclude_filter="bwrap|grep|konsole|dolphin|d3ddriverquery64.exe|fossilize_replay|legendary install"

run_stop() {
	nohup bash -c "${EXEC_FILE} stop 2>&1 | logger -t obs-studio-gaming.stopper" >/dev/null &
	disown
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

check_games_running() {
	check_obs

	games_text=$(pgrep -U "${user_id}" -a | grep -E "${include_filter}" | grep -Ev "${exclude_filter}")
	[ -z "${games_text}" ] && return 1

	return 0
}

start_obs() {
	OBS-Studio obs \
		--scene "Fullscreen" \
		--websocket_ipv4_only \
		--startreplaybuffer \
		--minimize-to-tray \
		--disable-shutdown-check \
		"$@"
}

run_obs() {
	screen_res=$(xrandr | awk '/primary/ {print $4}')
	echo "Starting OBS Studio with ReplayBuffer"

	run_stop

	if echo "${screen_res}" | grep -q '3840x2160'; then
		echo "Recording 16:9 at 3840x2160"
		start_obs --collection "Recording_16:9" --profile "ShadowPlay_16:9"
	elif echo "${screen_res}" | grep -q '3360x1440'; then
		echo "Recording 21:9 at 3360x1440"
		start_obs --collection "Recording_21:9" --profile "ShadowPlay_21:9"
	elif echo "${screen_res}" | grep -q '5120x1440'; then
		echo "Recording 32:9 at 5120x1440"
		start_obs --collection "Recording_32:9" --profile "ShadowPlay_32:9"
	else
		echo "Recording 32:9 at 5120x1440"
		start_obs --collection "Recording_32:9" --profile "ShadowPlay_32:9"
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
		kill $(pgrep '.obs-wrapped')
	;;
esac
