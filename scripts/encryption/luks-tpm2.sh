#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPT_DIR}/luks-tpm2-setup"

# enroll key to TPM 2.0
systemd-cryptenroll \
	--tpm2-device=auto \
	--tpm2-with-pin=${TPM_PIN} \
	--tpm2-pcrs=${tpm_regs} \
	"${luks_device}"
