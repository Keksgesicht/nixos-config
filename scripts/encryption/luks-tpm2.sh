#!/usr/bin/env bash -e

SCRIPT_DIR=$(dirname $(realpath $0))
source ${SCRIPT_DIR}/luks-tpm2-setup


# enroll key to TPM 2.0
systemd-cryptenroll \
	--tpm2-device=auto \
	--tpm2-with-pin=true \
	--tpm2-pcrs=${tpm_regs} \
	${luks_device}
