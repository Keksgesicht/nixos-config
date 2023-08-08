#!/run/current-system/sw/bin/bash -e

SCRIPT_DIR=$(dirname $(realpath $0))
source ${SCRIPT_DIR}/luks-tpm2-setup


# create keyfile
#umask 177
#mkdir -p -m 600 $(dirname ${keyfile})
#dd if=/dev/urandom of=${keyfile} iflag=fullblock bs=512 count=4

# replace password with keyfile
#cryptsetup luksAddKey ${luks_device} ${keyfile}

# create a recovery key
#systemd-cryptenroll --recovery-key --unlock-key-file=${keyfile} ${luks_device}

# enroll key to TPM 2.0
systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=true --tpm2-pcrs=${tpm_regs} ${luks_device}
