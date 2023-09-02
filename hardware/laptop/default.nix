{ config, pkgs, ... }:

{
  imports = [
    ../.
    ../x86_64-uefi.nix
    ../services.nix
    ../tpm2.nix
    ./filesystem.nix
    ./tuxedo.nix
  ];

  # extension to ../x86_64-uefi.nix
  boot.initrd.systemd.enable = true;
}
