#!/usr/bin/env bash

set -ex

TMP2_LIB_FILE="/run/current-system/sw/lib/libtpm2_pkcs11.so"

your_sopin() {
	[ -n "${YOUR_SOPIN}" ] && return

	read -p 'YOUR_SOPIN: ' YOUR_SOPIN
	while [ -z "${YOUR_SOPIN}" ]; do
		read -p 'YOUR_SOPIN: ' YOUR_SOPIN
	done
}

your_pin() {
	[ -n "${YOUR_PIN}" ] && return

	read -p 'YOUR_PIN: ' YOUR_PIN
	while [ -z "${YOUR_PIN}" ]; do
		read -p 'YOUR_PIN: ' YOUR_PIN
	done
}

if ! tpm2_ptool listprimaries | grep -q 'id: 1'; then
	tpm2_ptool init
fi

if ! tpm2_ptool listtokens --pid 1 | grep -q 'label: ssh'; then
	your_sopin
	your_pin

	tpm2_ptool addtoken \
		--pid=1 --label='ssh' \
		--userpin=${YOUR_PIN} \
		--sopin=${YOUR_SOPIN}
fi

if ! ssh-keygen -D ${TMP2_LIB_FILE} 2>/dev/null | grep -q 'tpm2@'; then
	your_pin

	tpm2_ptool addkey \
		--label='ssh' \
		--algorithm=ecc256 \
		--userpin=${YOUR_PIN} \
		--key-label "tpm2@$(hostname)"
fi

# copy this to remote ~/.config/ssh/tpm2_ecc256.pub
ssh-keygen -D ${TMP2_LIB_FILE} 2>/dev/null | \
	tee ${XDG_CONFIG_HOME}/ssh/tpm2_ecc256.pub
