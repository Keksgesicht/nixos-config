#!/usr/bin/env bash

umask 077
set -e

### check parameter

usage() {
	echo "$0 [NAME] [PEER NAME] [PEER ADDRESS]"
}

if [ "$#" != 3 ]; then
	usage
	exit 1
fi
HOST=$1
PEER_NAME=$2
PEER_ADDR=$3

### variables

UserName="keks"
ScriptDir=$(dirname "$(realpath "$0")")
GitRepoDir=$(git -C "${ScriptDir}" rev-parse --show-toplevel)
SecretsDir="/etc/nixos/secrets/keys/wireguard"
PublicDir="${GitRepoDir}/secrets/local/wireguard/public"

### create (secure) temporary directory

TMP=$(mktemp -d --suffix=".wireguard-keys")
cd "${TMP}" || exit 23

### generate keys

wg "genkey" > private
wg "pubkey" < private > public
wg "genpsk" > shared

### copy public and shared keys

umask 022

mkdir -p ${SecretsDir}/shared
mkdir -p "${PublicDir}"

cp shared  ${SecretsDir}/shared/"${HOST}-${PEER_NAME}"
mv public "${PublicDir}"/"${HOST}-${PEER_NAME}"

chown -R ${UserName}:${UserName} "$(dirname "${PublicDir}")"
chmod 644 "${PublicDir}"/"${HOST}"

### create config

IP_PREFIX_V4="192.168.176"
IP_PREFIX_V6="fd00:2307"
CONF_FILE="wg.conf"

{
	echo "[Interface]"
	echo -n "PrivateKey="; cat private
	echo "Address=${IP_PREFIX_V4}.222/24, ${IP_PREFIX_V6}::222/64"
	echo "DNS=${IP_PREFIX_V4}.2, ${IP_PREFIX_V4}.1"

	echo ""

	echo "[Peer]"
	echo -n "PresharedKey="; cat shared
	echo -n "PublicKey="; cat "${PublicDir}"/"${PEER_NAME}";
	echo "Endpoint=${PEER_ADDR}"
	echo "AllowedIPs=0.0.0.0/0, ::/0"
} > ${CONF_FILE}

### generate QR code

cat ${CONF_FILE} | qrencode -t UTF8
