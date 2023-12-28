{ config, lib, ... }:

{
  imports = [
    #./binfmt.nix
    ./uefi.nix
    ../.
    ../development

    ../security/secure-boot.nix
    ../security/tpm2.nix
    ../services/btrfs.nix
    ../services/firmware.nix
    ../services/monitoring.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
