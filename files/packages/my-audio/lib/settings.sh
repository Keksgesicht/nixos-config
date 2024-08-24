my_mic_list=""
my_mic_list+=" alsa_input.usb-Auna_Mic_CM900_Auna_Mic_CM900-00.mono-fallback"
my_mic_list+=" bluez_input.00_25_BB_03_70_3D.0"
my_mic_list+=" "

if [ "$(cat /etc/hostname)" = "cookieclicker" ]; then
	echo_in='mic_filter_sink'
else
	echo_in='virt_mic_sink'
fi
central_sink='echo_out_sink'
scatter_source='echo_out_source'


link_ports() {
	pw-link "$1" "$2"
}

link_left() {
	for node_right_in in $(pw-link -i | grep "$2" | grep -E '_([FR]L|1|MONO|AUX0)$'); do
		link_ports "$1" "$node_right_in"
	done
}
link_right() {
	for node_right_in in $(pw-link -i | grep "$2" | grep -E '_([FR]R|2|MONO|AUX1)$'); do
		link_ports "$1" "$node_right_in"
	done
}
link_mono() {
	for node_right_in in $(pw-link -i | grep "$2"); do
		link_ports "$1" "$node_right_in"
	done
}

link_nodes() {
	for node_left_out in $(pw-link -o | grep "$1" | grep -E '_([FR]L|1|AUX0)$'); do
		link_left "$node_left_out" "$2"
	done

	for node_left_out in $(pw-link -o | grep "$1" | grep -E '_([FR]R|2|AUX1)$'); do
		link_right "$node_left_out" "$2"
	done

	for node_left_out in $(pw-link -o | grep "$1" | grep -E '_(MONO)$'); do
		link_mono "$node_left_out" "$2"
	done
}


unlink_inputs() {
	for id in $(pw-link -I -l | grep '|->' | awk '/'"$1"'/ {print $1}'); do
		pw-link -d "$id"
	done
}
unlink_outputs() {
	for id in $(pw-link -I -l | grep '|<-' | awk '/'"$1"'/ {print $1}'); do
		pw-link -d "$id"
	done
}
unlink_node() {
	unlink_inputs "${1}_sink"
	unlink_outputs "${1}_source"
}
