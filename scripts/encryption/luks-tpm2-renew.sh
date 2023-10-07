#!/run/current-system/sw/bin/bash -e

SCRIPT_DIR=$(dirname $(realpath $0))
source ${SCRIPT_DIR}/luks-tpm2-setup


# reenroll key to TPM 2.0
systemd-cryptenroll --wipe-slot=tpm2 ${luks_device}
sleep 1s
systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=true --tpm2-pcrs=${tpm_regs} ${luks_device}
