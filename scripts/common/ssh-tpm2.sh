#!/usr/bin/env bash

read -p 'YOUR_SOPIN: ' YOUR_SOPIN
while [ -z "${YOUR_SOPIN}" ]; do
	read -p 'YOUR_SOPIN: ' YOUR_SOPIN
done

read -p 'YOUR_PIN: '   YOUR_PIN
while [ -z "${YOUR_PIN}" ]; do
	read -p 'YOUR_PIN: ' YOUR_PIN
done

if ! tpm2_ptool listprimaries | grep -q 'id: 1'; then
	tpm2_ptool init
fi

tpm2_ptool addtoken \
	--pid=1 --label='ssh' \
	--userpin=${YOUR_PIN} \
	--sopin=${YOUR_SOPIN}

tpm2_ptool addkey \
	--label='ssh' \
	--algorithm=ecc256 \
	--userpin=${YOUR_PIN} \
	--key-label "tpm2@$(hostname)" \

# ~/.config/ssh/tpm2_ecc256.pub
ssh-keygen -D /run/current-system/sw/lib/libtpm2_pkcs11.so
