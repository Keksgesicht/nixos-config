{ config, pkgs, ...}:

{
  # https://nixos.wiki/wiki/TPM
  security.tpm2 = {
    enable = true;
    # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    pkcs11.enable = true;
    # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
    tctiEnvironment.enable = true;
  };

  # tss group has access to TPM devices
  users.users.keks.extraGroups = [ "tss" ];
}
