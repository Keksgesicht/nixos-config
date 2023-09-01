#!/bin/bash

LOGLEVEL=3
source_mic="virt_mic_source"
source_chat="vban_chat_source"

pw_node_id() {
io=$1
name=$2
pw-cli dump short Node | grep "${io}" | awk -F':' '/'${name}'/ {print $1}'
}

vban_run() {
name=$1
shift
nohup $@ --description=${name} >/dev/null 2>&1 &
disown
}

stop() {
killall vban_emitter
killall vban_receptor
}

start() {
id_mic=$(pw_node_id 'o=' "$source_mic")
id_chat=$(pw_node_id 'o=' "$source_chat")

VBAN_IP=192.168.178.153
vban_run	'linux_mic'       vban_emitter  -l $LOGLEVEL -i $VBAN_IP -p 6982 -s mic    -b pipewire -r 48000 -f 24I -d $id_mic
vban_run	'linux_chat'      vban_emitter  -l $LOGLEVEL -i $VBAN_IP -p 6983 -s chat   -b pipewire -r 48000 -f 24I -d $id_chat
vban_run	'linux_gaming'    vban_receptor -l $LOGLEVEL -i $VBAN_IP -p 6981 -s gaming -b pipewire

VBAN_IP=192.168.178.154
vban_run	'windows_mic'     vban_emitter  -l $LOGLEVEL -i $VBAN_IP -p 6980 -s mic    -b pipewire -r 48000 -f 24I -d $id_mic
vban_run	'windows_chat'    vban_emitter  -l $LOGLEVEL -i $VBAN_IP -p 6980 -s chat   -b pipewire -r 48000 -f 24I -d $id_chat
vban_run	'windows_gaming'  vban_receptor -l $LOGLEVEL -i $VBAN_IP -p 6980 -s gaming -b pipewire
}

status() {
ps aux | grep 'vban_'
}

restart() {
stop
sleep 0.5s
start
sleep 0.1s
}

case $1 in
start | stop | restart | status)
	$1
;;
*)
	restart
	status
;;
esac
