{ config, ... }:

{
  imports = [
    #./binfmt.nix
    ./uefi.nix

    ../development
    ../security/secure-boot.nix
    ../security/tpm2.nix
    ../services/btrfs.nix
    ../services/firmware.nix
    ../services/monitoring.nix
    ../services/power-management.nix
  ];
}
