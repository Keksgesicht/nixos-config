#!/usr/bin/env bash

# https://www.wireguard.com/quickstart/

umask 077
set -e

UserName="keks"
ScriptDir=$(dirname "$(realpath "$0")")
GitRepoDir=$(git -C "${ScriptDir}" rev-parse --show-toplevel)
SecretsDir="/etc/nixos/secrets/keys/wireguard"
PublicDir="${GitRepoDir}/secrets/local/wireguard/public"

TMP=$(mktemp -d --suffix=".wireguard-keys")
cd "${TMP}" || exit 23

wg "genkey" > private
wg "pubkey" < private > public
wg "genpsk" > shared

umask 022

mkdir -p ${SecretsDir}/private
mkdir -p ${SecretsDir}/shared
mkdir -p "${PublicDir}"

mv private ${SecretsDir}/private/"${HOST}"
mv shared  ${SecretsDir}/shared/"${HOST}"
mv public "${PublicDir}"/"${HOST}"

chown -R ${UserName}:${UserName} "$(dirname "${PublicDir}")"
chmod 644 "${PublicDir}"/"${HOST}"

ls -l ${SecretsDir}/private/"${HOST}"
ls -l ${SecretsDir}/shared/"${HOST}"
ls -l "${PublicDir}"/"${HOST}"
